module CoreUtils
  def build_error_string(e)
    [e, e.message, e.backtrace]
    .map { |err| err.ai(html: true) }
    .join("<br>")
  end
end