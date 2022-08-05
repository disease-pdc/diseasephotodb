require "active_support/concern"

module CsvStreamable
  extend ActiveSupport::Concern

  def stream_csv_response args
    headers.delete("Content-Length")
    headers["Cache-Control"] = "no-cache"
    headers["Content-Type"] = "text/csv"
    headers["Content-Disposition"] = "attachment; filename=\"#{args[:filename]}\""
    headers["X-Accel-Buffering"] = "no"
    response.status = 200
    self.response_body = args[:enumerator]
  end

end
