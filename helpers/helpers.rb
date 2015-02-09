module AppHelpers

  def current_user
    if session[:user_id]
      return User.find(session[:user_id])
    else
      return nil
    end
  end

  def access
    if current_user == nil
      set_error ("Please login or signup for full access")
      redirect('/login')
    end
  end

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

end