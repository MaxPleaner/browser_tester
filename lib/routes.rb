class MainServer

  get ['/', '/browser'] do
    slim :root
  end

  post '/browser' do
    @results, @err = Browser.execute_command(params[:cmd])
    slim :root
  end
  
end