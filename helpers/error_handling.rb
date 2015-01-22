def display_error
  error = session[:error]
  session[:error] = nil

  if error
    return erb:'error/error_display', layout: false, locals: {errors: error}
  else
    return ""
  end
end

def set_error (msg)
  session[:error] = {"Error" => [msg]}
end