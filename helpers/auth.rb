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