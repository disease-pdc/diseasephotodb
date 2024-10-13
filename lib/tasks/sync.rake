require 'fileutils'

BASE_URL = "https://eva.mobileodt.com/Login"
PARTICIPANT_ID_KEY = 'participant_id'
DATE_UPDATED_KEY = 'date_updated'
IMAGE_INDEX_KEY = 'image_sequence'

def wait_for_at_xpath browser, path, tries=8
  current_try = tries
  loop do
    sleep(rand(2..4))
    element = browser.at_xpath path
    if !element.blank?
      return element
    else
      tries = tries - 1
    end
    raise "Waited too long for #{path}" if tries <= 0
  end
end
def wait_for_xpath browser, path, tries=8
  current_try = tries
  loop do
    sleep(rand(2..4))
    element = browser.xpath path
    if !element.blank?
      return element
    else
      tries = tries - 1
    end
    raise "Waited too long for #{path}" if tries <= 0
  end
end

def create_participant participant_id, date_updated, image_source_id, sync_user_id, image_paths
  image_paths.each_with_index do |image_path, index|
    image = Image.where(image_source_id: image_source_id, filename: File.basename(image_path)).first
    unless image
      image = Image.new(
        image_source_id: image_source_id,
        filename: File.basename(image_path),
        mime_type: 'image/png',
        user_id: sync_user_id,
        image_file: { 
          io: File.open(image_path), 
          filename: File.basename(image_path),
          content_type: "image/png"
        },
        metadata: {
          "participant_id" => participant_id,
          "date_updated" => date_updated.to_s,
          "synced_at" => DateTime.now,
          "image_sequence" => index + 1
        }
      )
      image.save!
    end
  end
  image_set = ImageSet.where(name: participant_id).first
  image_set.metadata = (image_set.metadata || {}).merge({
    "participant_id" => participant_id,
    "date_updated" => date_updated.to_s,
    "synced_at" => DateTime.now,
    "image_count" => image_paths.length
  })
  image_set.save!
end

def load_participant browser, participant_id, image_source_id, sync_user_id, date_updated
  image_folder = "#{Dir.pwd}/tmp/participants/#{participant_id}"
  image_set = ImageSet.search(
    image_source_id: image_source_id,
    metadata_key: PARTICIPANT_ID_KEY, 
    metadata_value_eq: participant_id
  ).first
  if image_set
    puts "#{participant_id} already loaded, skipping"
    return
  end 
  img = wait_for_at_xpath browser, "//div[@class='files']//img"
  img.scroll_into_view
  unless img
    puts "[ERROR] #{participant_id} unable to find files link"
    return
  end
  img.click
  
  # Download to participant folder
  browser.downloads.set_behavior(
    save_path: image_folder, 
    behavior: :allow
  )
  image_seq = 1

  loop do
    # Find download button
    # browser.mouse.scroll_to(0, 600)
    btns = wait_for_xpath browser, "//div[@class='bottom-btns']//div[@class='section']//button"
    browser.screenshot(path: "screenshot-annotation-bottom-buttons.png")
    if btns[0]
      btn_label = btns[0].at_xpath "span[@class='label']"
      if !(btn_label.inner_text.include?('Download'))
        puts "[ERROR] Unable to find download link"
        return
      end
    else
      puts "[ERROR] Annotation bottom buttons not loaded"
      return
    end
    # Download file
    puts "Downloading image sequence #{image_seq} for participant_id #{participant_id}"
    browser.downloads.wait { btns[0].click }

    # Click next
    nav_btns = browser.xpath "//div[@class='annotations']//button[contains(@class,'arrow')]"
    next_btn = nav_btns.find {|btn| btn.at_xpath("*[name()='svg']").attribute('class').include?('right')}
    if !next_btn
      puts "[ERROR] Unable to find annotations next link"
      return
    end
    break if next_btn.attribute('class').include?('disabled')
    image_seq = image_seq + 1
    next_svg = next_btn.at_xpath("*[name()='svg']")
    next_svg.click
  end

  puts "Found #{image_seq} images for participant_id #{participant_id}"
  image_paths = Dir["#{image_folder}/*"].sort_by{ |f| File.mtime(f) }
  create_participant participant_id, date_updated, image_source_id, sync_user_id, image_paths

  # Delete downloaded images
  FileUtils.rm_rf(image_folder)
end

def participant_loaded? image_source_id, participant_id
  ImageSet.search(
    image_source_id: image_source_id,
    metadata_key: PARTICIPANT_ID_KEY, 
    metadata_value_eq: participant_id
  ).exists?
end

def sync_password_for username
  JSON.parse(ENV['SYNC_CREDENTIALS'])[username]
end

namespace :sync do

  desc "Sync patients on profile"
  task :patients, [:email, :image_source_id, :sync_user_id, :last_updated] => :environment do |task, args|
    email = args[:email]
    password = sync_password_for(email)
    image_source_id = args[:image_source_id]
    sync_user_id = args[:sync_user_id]
    last_updated = args[:last_updated] ? Date.parse(args[:last_updated]) : 2.days.ago

    begin
      browser = Ferrum::Browser.new(browser_options: { 'no-sandbox': nil })
      browser.go_to BASE_URL
      email_input = wait_for_at_xpath browser, "//input[@class='email' and @type='email']"
      email_input.focus.type email
      pw_input = browser.at_xpath "//input[@class='password' and @type='password']"
      pw_input.focus.type password
      browser.at_xpath("//button[@class='login-btn']").click
      puts "Logged In"

      accept_cookies = wait_for_at_xpath browser, "//button[@class='accept']"
      if accept_cookies
        puts "Accepting cookies"
        accept_cookies.click
      end 

      # Iterate over patients and pages until patient 
      current_patient_tr_index = 0
      loop do
        patient_trs = wait_for_xpath browser, "//div[@class='patients-content']//table//tbody//tr"
        patient_tr = patient_trs[current_patient_tr_index]

        patient_tr.scroll_into_view
        tds = patient_tr.xpath "td"
        participant_id = tds[2].inner_text
        date_updated = Date.parse(tds[4].inner_text)
        if date_updated < last_updated
          "Found participant #{participant_id} with #{date_updated} before limit, ending sync"
          break
        end
        unless participant_loaded?(image_source_id, participant_id)
          puts "Found new participant #{participant_id} updated at #{date_updated}"
          patient_tr.click
          load_participant browser, participant_id, image_source_id, sync_user_id, date_updated

          # Back to main list
          browser.at_xpath("//a[@class='close']").click
          wait_for_at_xpath(browser, "//a[@class='back-btn']").click
          patient_trs = wait_for_xpath browser, "//div[@class='patients-content']//table//tbody//tr"
          puts "Back to patient_trs, length #{patient_trs.length}"
          browser.screenshot(path: "screenshot-patients.png")
        end
        current_patient_tr_index = current_patient_tr_index + 1
        if current_patient_tr_index >= patient_trs.length
          next_btn = browser.at_xpath("//div[@class='actions']//button[@class='next'")
          # If Next disabled, on last page
          if (next_btn.attribute['disabled'])
            break;
          end
          next_btn.click
          current_patient_tr_index = 0
          sleep(1) # Wait 1 second for event to propagate
        end
      end

    rescue => exception
      puts exception.backtrace
      raise # always reraise

    ensure
      browser.quit
    end

  end

end
