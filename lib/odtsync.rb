# frozen_string_literal: true
require 'fileutils'

class Odtsync
  # Constants
  BASE_URL = "https://eva.mobileodt.com/Login"
  DATE_UPDATED_KEY = 'date_updated'
  IMAGE_INDEX_KEY = 'image_sequence'
  MAX_SYNCED = 50

  # Class methods
  def self.participant_code(participant_id, date_updated)
    "#{participant_id}-#{date_updated.to_s}"
  end

  def self.sync_password_for(username)
    JSON.parse(ENV['SYNC_CREDENTIALS'])[username]
  end

  # Instance properties and methods
  attr_reader :browser, :email

  def initialize(email)
    @email = email
    password = self.class.sync_password_for(email)
    @browser = login_new_browser(password)
  end

  def wait_for_at_xpath(path, tries=8)
    current_try = tries
    loop do
      element = @browser.at_xpath path
      if !element.blank?
        return element
      else
        tries = tries - 1
      end
      sleep(rand(2..4))
      raise "Waited too long for #{path}" if tries <= 0
    end
  end

  def wait_for_xpath(path, tries=8)
    current_try = tries
    loop do
      element = @browser.xpath path
      if !element.blank?
        return element
      else
        tries = tries - 1
      end
      sleep(rand(2..4))
      raise "Waited too long for #{path}" if tries <= 0
    end
  end

  def patient_trs_on_page(page_num)
    cur_page = 0
    while cur_page < page_num
      next_button = wait_for_at_xpath("//div[@class='actions']//button[@class='next']")
      # If Next disabled, on last page
      if (next_button.attribute('disabled'))
        puts "Next button disabled, finishing"
        return nil
      end
      next_button.scroll_into_view
      next_button.click
      sleep(1)
      cur_page += 1
    end
    return wait_for_xpath("//div[@class='patients-content']//table//tbody//tr")
  end

  def create_participant(participant_id, date_updated, clinician_name, image_source_id, sync_user_id, image_paths)
    puts "Creating participant #{participant_id} with #{image_paths.length} images, date_updated: #{date_updated}"
    image_source = ImageSource.find image_source_id
    participant_id_key = image_source.create_image_sets_metadata_field
    image_paths.each_with_index do |image_path, index|
      image = Image.where(image_source_id: image_source_id, filename: File.basename(image_path)).first
      if image
        puts "Skipping existing image #{image_path} for participant #{participant_id}"
      else
        puts "Creating new image #{image_path} for participant #{participant_id}"
        metadata = {
          "date_updated" => date_updated.to_s,
          "synced_at" => DateTime.now,
          "image_sequence" => index + 1,
          "pid" => participant_id,
          "clinician_name" => clinician_name
        }
        metadata[participant_id_key] = self.class.participant_code(participant_id, date_updated)
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
          metadata: metadata
        )
        image.save!
      end
    end
    sleep(1) # Wait for image_set
    image_set = ImageSet.where(name: self.class.participant_code(participant_id, date_updated)).first
    if image_set
      puts "Updating image set #{image_set.id}, participant #{participant_id}"
      metadata = {
        "date_updated" => date_updated.to_s,
        "synced_at" => DateTime.now,
        "image_count" => image_paths.length,
        "pid" => participant_id,
        "clinician_name" => clinician_name
      }
      metadata[participant_id_key] = self.class.participant_code(participant_id, date_updated)
      image_set.metadata = (image_set.metadata || {}).merge(metadata)
      image_set.save!
    else
      puts "[ERROR] Failed to find image set for participant #{participant_id}, date_updated: #{date_updated}"
    end
  end

  def load_participant(participant_id, image_source_id, sync_user_id, date_updated)
    image_source = ImageSource.find image_source_id
    participant_id_key = image_source.create_image_sets_metadata_field
    image_folder = "#{Dir.pwd}/tmp/participants/#{participant_id}"
    image_set = ImageSet.search(
      image_source_id: image_source_id,
      metadata_key: participant_id_key, 
      metadata_value_eq: self.class.participant_code(participant_id, date_updated)
    ).first
    sleep(2)
    # Load clinician:
    clinician_name = ""
    exam_details_array = wait_for_xpath("//div[@class='exam-section-content']")
    exam_details_array.each do |exam_details|
      label = exam_details.at_xpath("p[@class='label']")
      if label && label.inner_text.downcase.include?('clinician')
        info = exam_details.at_xpath("p[@class='info']")
        if info && info.inner_text
          clinician_name = info.inner_text
        end
      end
    end

    msg = @browser.at_xpath "//div[@class='files']//p"
    if (msg && msg.inner_text.squish == 'There are no media files')
      puts "[ERROR] #{participant_id} reports no files"
      return {skip: participant_id}
    end
    img = wait_for_at_xpath("//div[@class='files']//img")
    img.scroll_into_view
    unless img
      puts "[ERROR] #{participant_id} unable to find files link"
      return
    end
    img.click
    
    # Download to participant folder
    @browser.downloads.set_behavior(
      save_path: image_folder, 
      behavior: :allow
    )
    image_seq = 1

    loop do
      # Find download button
      # @browser.mouse.scroll_to(0, 600)
      btns = wait_for_xpath("//div[@class='bottom-btns']//div[@class='section']//button")
      @browser.screenshot(path: "screenshot-annotation-bottom-buttons.png")
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
      @browser.downloads.wait { btns[0].click }

      # Click next
      nav_btns = wait_for_xpath("//div[@class='annotations']//button[contains(@class,'arrow')]")
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
    sleep(2) # Wait for temp files to clear
    image_paths = Dir["#{image_folder}/*"].sort_by{ |f| File.mtime(f) }
    create_participant(participant_id, date_updated, clinician_name, image_source_id, sync_user_id, image_paths)

    # Delete downloaded images
    FileUtils.rm_rf(image_folder)
  end



  # Convert to instance method - now takes just password (email from constructor)
  def login_new_browser(password)
    @browser = Ferrum::Browser.new(browser_options: { 'no-sandbox': nil }, headless: "new", window_size: [1024, 1400], timeout: 15)
    @browser.go_to BASE_URL
    email_input = wait_for_at_xpath "//input[@class='email' and @type='email']"
    email_input.focus.type @email
    pw_input = wait_for_at_xpath "//input[@class='password' and @type='password']"
    pw_input.focus.type password
    wait_for_at_xpath("//button[@class='login-btn']").click
    puts "Logged In"

    accept_cookies = wait_for_at_xpath("//button[@class='accept']")
    if accept_cookies
      puts "Accepting cookies"
      accept_cookies.click
    end
    return @browser
  end

  # Instance method that depends on browser
  def participant_loaded?(image_source_id, participant_id, date_updated)
    image_source = ImageSource.find image_source_id
    participant_id_key = image_source.create_image_sets_metadata_field
    ImageSet.search(
      image_source_id: image_source_id,
      metadata_key: participant_id_key, 
      metadata_value_eq: self.class.participant_code(participant_id, date_updated)
    ).exists?
  end

  # Syncs patients based on provided parameters
  # @param params [Hash] Parameters for syncing
  #   @option params [String/Integer] :image_source_id ID of the image source
  #   @option params [String/Integer] :sync_user_id ID of the sync user
  #   @option params [String/Integer] :last_updated_days Number of days to look back (default: 2)
  #   @option params [String] :start_pid Patient ID to start syncing from (default: '')
  #   @option params [Boolean] :validate Whether to validate (default: false)
  # @return [Array] List of synced patient IDs
  def sync_patients(params = {})
    # Extract parameters with defaults
    image_source_id = params[:image_source_id]
    sync_user_id = params[:sync_user_id]
    last_updated = params[:last_updated_days] ? 
      params[:last_updated_days].to_i.days.ago.beginning_of_day : 
      2.days.ago
    start_pid = params[:start_pid] || ''
    validate = params[:validate] || false

    # Track sync status
    num_synced = 0
    skip_ids = []
    current_page = 0
    synced_patients = []

    begin
      # Iterate over patients and pages until patient 
      current_patient_tr_index = 0
      patient_trs = patient_trs_on_page(current_page)
      
      loop do
        patient_tr = patient_trs[current_patient_tr_index]

        patient_tr.scroll_into_view
        tds = patient_tr.xpath "td"
        participant_id = tds[2].inner_text
        date_updated = Date.parse(tds[4].inner_text)
        
        if date_updated < last_updated
          puts "Found participant #{participant_id} with #{date_updated} before limit, ending sync"
          break
        end
        
        if !start_pid.blank? && participant_id.squish != start_pid.squish
          puts "Found participant #{participant_id} before start_pid, skipping"
          current_patient_tr_index += 1
          if current_patient_tr_index >= patient_trs.length
            puts "At patient tr index #{current_patient_tr_index} of #{patient_trs.length}, going to next"
            current_page += 1
            num_synced = num_synced + 1
            current_patient_tr_index = 0
            patient_trs = patient_trs_on_page(current_page)
          end
          next
        end
        
        start_pid = nil
        puts "Found start participant #{participant_id}, continuing"
        
        if validate || (!skip_ids.include?(participant_id) && !participant_loaded?(image_source_id, participant_id, date_updated))
          puts "Found participant #{participant_id} updated at #{date_updated}, index #{current_patient_tr_index} in table"
          patient_tr.click
          load_results = load_participant(participant_id, image_source_id, sync_user_id, date_updated)

          if load_results && load_results.is_a?(Hash) && !load_results[:skip].blank?
            skip_ids << load_results[:skip]
          else
            synced_patients << participant_id
          end

          # Back to main list
          close_button = @browser.at_xpath("//a[@class='close']")
          close_button.click if close_button
          wait_for_at_xpath("//a[@class='back-btn']").click
          patient_trs = wait_for_xpath("//div[@class='patients-content']//table//tbody//tr")
          num_synced = num_synced + 1
          puts "Back to patient_trs, length #{patient_trs.length}"
        end
        
        current_patient_tr_index = current_patient_tr_index + 1
        if current_patient_tr_index >= patient_trs.length
          puts "At patient tr index #{current_patient_tr_index} of #{patient_trs.length}, going to next"
          current_page += 1
          num_synced = num_synced + 1
          current_patient_tr_index = 0
        end
        
        if num_synced > Odtsync::MAX_SYNCED
          puts "Synced more than #{Odtsync::MAX_SYNCED}, restarting browser"
          @browser.reset
          @browser.quit
          login_new_browser(self.class.sync_password_for(@email))
          num_synced = 0 
        end
        
        patient_trs = patient_trs_on_page(current_page)
      end

      return synced_patients
      
    rescue => exception
      puts exception.backtrace
      @browser.screenshot(path: "screenshot-exception.png")
      raise # always reraise
    ensure
      # Always clean up browser resources
      @browser.reset
      @browser.quit
    end
  end
  
  # Syncs a specific patient by ID
  # @param participant_id [String] ID of the participant to sync
  # @param image_source_id [String/Integer] ID of the image source
  # @param sync_user_id [String/Integer] ID of the sync user
  # @return [Hash/nil] Result of loading the participant
  def sync_patient(participant_id, image_source_id, sync_user_id)
    result = nil
    current_page = 0
    found = false
    
    begin
      # Start searching from page 0
      loop do
        puts "Searching for participant #{participant_id} on page #{current_page}"
        patient_trs = patient_trs_on_page(current_page)
        
        # Check if we got any patient rows
        if patient_trs.empty?
          puts "No more patient records found on page #{current_page}"
          break
        end
        
        # Iterate through each patient row on this page
        patient_trs.each_with_index do |patient_tr, index|
          # Scroll row into view to ensure it's visible
          patient_tr.scroll_into_view
          
          # Extract patient ID and date from row
          tds = patient_tr.xpath "td"
          current_id = tds[2].inner_text
          date_updated = Date.parse(tds[4].inner_text)
          
          # Check if this is the patient we're looking for
          if current_id.squish == participant_id.squish
            puts "Found target participant #{participant_id} on page #{current_page}, index #{index}"
            found = true
            
            # Click on the patient row to load details
            patient_tr.click
            
            # Load the participant data
            result = load_participant(participant_id, image_source_id, sync_user_id, date_updated)
            
            # Close patient view and return to list
            close_button = @browser.at_xpath("//a[@class='close']")
            close_button.click if close_button
            wait_for_at_xpath("//a[@class='back-btn']").click
            
            puts "Successfully processed participant #{participant_id}"
            break
          end
        end
        
        # If we found the participant, exit the loop
        break if found
        
        # Move to the next page if we didn't find the participant
        current_page += 1
      end
      
      if !found
        puts "Could not find participant #{participant_id} in any page"
      end
      
      return result
    rescue => exception
      puts exception.backtrace
      @browser.screenshot(path: "screenshot-exception-#{participant_id}.png")
      raise # always reraise
    ensure
      # Always clean up browser resources
      @browser.reset
      @browser.quit
    end
  end
end
