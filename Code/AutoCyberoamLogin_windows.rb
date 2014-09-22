require 'cipher.rb'
$filepath = File.join(  ENV['HOME'] ,".userdetails")
$repeating_seconds = -1
$showtimer = false
$repeating_seconds = get_repeating_seconds.to_s rescue ""
if not $repeating_seconds.empty?
  $repeating_seconds = $repeating_seconds.to_i
  $showtimer = true  
else
  $showtimer = false
  $repeating_seconds = -1
end
def cyberoam( username , password , login = true)
  login_curl = "curl --silent 'https://10.100.56.55:8090/login.xml' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.5' -H 'Cache-Control: no-cache' -H 'Connection: keep-alive' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Host: 10.100.56.55:8090' -H 'Pragma: no-cache' -H 'Referer: https://10.100.56.55:8090/httpclient.html' --data 'mode=191&username=#{username}&password=#{password}&a=1407179385601&producttype=0' -k --max-time 0.4"
  logout_curl = "curl --silent 'https://10.100.56.55:8090/logout.xml' -H 'Host: 10.100.56.55:8090' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Referer: https://10.100.56.55:8090/httpclient.html' -H 'Connection: keep-alive' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' --data 'mode=193&username=#{username}&a=1407179351402&producttype=0' -k --max-time 0.4"
  if login
    loginresponse = `#{login_curl}`
    return loginresponse , (not loginresponse.empty? )
  else
    logoutresponse = `#{logout_curl}`
    return logoutresponse , ( not logoutresponse.empty? )
  end
end

Shoes.setup do
 gem 'nori'
 gem 'nokogiri'
end
require 'nori'
require 'nokogiri'

def cache_details(username , password)   
   repeating_seconds = get_repeating_seconds
   file = File.new($filepath , 'w') 
     file.puts "username::>#{username}"
     file.puts "password::>#{password}"
     file.puts "repeating_seconds::>#{repeating_seconds}" if not repeating_seconds.strip.empty?
   file.close
end
def save_repeating_time(repeating_seconds)
   username = get_username
   password = get_password
   if( (not username.empty?) and (not password.empty?) )
       file = File.new($filepath , 'w') 
         file.puts "username::>#{username}"
         file.puts "password::>#{password}"
         file.puts "repeating_seconds::>#{repeating_seconds}"
       file.close
       return true
    else
       return false
    end
end
def unsave_repeating_time
   username = get_username
   password = get_password
   if( (not username.empty?) and (not password.empty?) )
       file = File.new($filepath , 'w') 
         file.puts "username::>#{username}"
         file.puts "password::>#{password}"
       file.close
    end
end
def get_username
  return "" if not File.exists?($filepath)
  file = File.new( $filepath , 'r') rescue nil
  if not file.nil? and file.stat.readable?
              file.each_line do |line| 
                      return line.strip.split('::>')[1].chomp.to_s if line.include?('username::>')
              end
    return ""
  end
  return ""
end

def get_password
  return "" if not File.exists?($filepath)
    file = File.new( $filepath , 'r') rescue nil
    if not file.nil? and file.stat.readable?
            file.each_line do |line| 
                    return line.strip.split('::>')[1].chomp.to_s if line.include?('password::>')
            end
    return ""
  end
  return ""
end
def get_repeating_seconds
  return "" if not File.exists?($filepath)
  file = File.new( $filepath , 'r') rescue nil
  if not file.nil? and file.stat.readable?
      file.each_line do |line| 
        return line.strip.split('::>')[1].chomp.to_s if line.include?('repeating_seconds::>')
      end
      return ""
  end
  return ""
end

  def attempt_login(username , password)
    loginresponse , network_available = cyberoam(username , password, true)
    if network_available
        parser = Nori.new 
        response_message = parser.parse(loginresponse)["requestresponse"]["message"] rescue ""
        @response.replace(response_message , :stroke => green)
    else
        @response.replace("Network is Unavailable!" , :stroke => red)        
    end
  end

  def show_timer(app , seconds , timer_seconds)
    app.timer(seconds) do |x| 
      if $showtimer == true
        @time_elapsed.replace( "Time Elapsed : " + "#{Time.at(timer_seconds).gmtime.strftime('%R:%S')}" , :align => "center")
        if timer_seconds < $repeating_seconds
          show_timer(app , seconds , timer_seconds + 1 )
        else
          attempt_login( @username.text , @password.text)
          show_timer(app , seconds , 1 )
        end
      end
    end
  end

  def details_valid?(username , password="randompassword")
    if not username.empty? and not password.empty?
      return true
    else
      return false
    end
  end


Shoes.app :title => "Auto Cyberoam Login" , :width => 340, :height => 490 , :scroll => true , :resizable => false do
  parser = Nori.new 
  background "#EFC".."AAD271"
  border( "AAD271".."#3D6919", strokewidth: 6)
  @app = self
  curl_installed = `curl --version` rescue false
  if not curl_installed
    alert("I dont think you have \"cURL\" installed. Please make sure that are able to run \'curl\' command running on your terminal. \n If you are on ubuntu , try: sudo apt-get install curl or for windows visit: http://www.confusedbycode.com/curl/")
    self.close
  end
  
  stack :margin_left => 40 , :margin_right => 40 , :margin_top => 20 , :margin_bottom => 0 do
    @response = para ""
    stack :margin => 5 do
      para(strong("User Name") , :stroke => rgb(82,47,35))
      @username = edit_line(:width => '100%')     
      @username.text=get_username
    end
    stack :margin => 5 do
      para(strong("Password") , :stroke => rgb(82,47,35) )
      @password = edit_line(:secret => true , :width => '100%')
      @password.text=get_password
    end
    flow :margin => 5 , :align => 'center' do
      button "LogIn" , :width => '50%' , :margin => 5 do
         if details_valid?(@username.text , @password.text)
           loginresponse  , network_available = cyberoam(@username.text , @password.text , true)
           parser.parse(loginresponse)
           if network_available
               response_message = parser.parse(loginresponse)["requestresponse"]["message"]
               if response_message.include?("logged in")
                 @response.replace(response_message  , :stroke => green) 
               else
                 @response.replace(response_message  , :stroke => red) 
               end
           else
               @response.replace("Network is Unavailable!" , :stroke => red)
           end
         else
           alert("Username or password cant be blank!")
         end
      end
      button "LogOut" , :width => '50%' , :margin => 5 do
         if details_valid?(@username.text )
           logoutresponse  , network_available = cyberoam(@username.text , @password.text , false)
           parser.parse(logoutresponse)
           if network_available
               response_message = parser.parse(logoutresponse)["requestresponse"]["message"]
               if response_message.include?("logged off")
                  @response.replace(response_message , :stroke => green)  
               else
                  @response.replace(response_message , :stroke => red)  if not response_message.include?("logged off")
               end
           else
               @response.replace("Network is Unavailable!" , :stroke => red)
           end
          else
             alert("Username cant be blank!")
          end
       end
      button "Remember Details" , :width => '100%' , :margin => 5 do
         if details_valid?(@username.text , @password.text)
           cache_details(@username.text , @password.text)
           @response.replace("User Name and Password saved!" , :stroke => green)
         else
           alert("Username or password cant be blank!")
         end
      end
    end
    @prefinal_flow = flow :margin => 5 , :width => '100%' , :align => 'center' do
        para strong("Auto Login ?") , :stroke => rgb(82,47,35)
        @checkbox = check do
              if @checkbox.checked
                      Shoes.debug("AAA  #{@para}   ... #{@repeating_hours}")
                      Shoes.debug("COMA  #{( (@para.nil? rescue true) and (@repeating_hours.nil? rescue true) )}")
                      if( (@para.nil? rescue true) and (@repeating_hours.nil? rescue true) )
                      @prefinal_flow.append do
                          @para = para strong("Minutes") , :stroke => rgb(82,47,35)
                          @repeating_hours = edit_line(:width => 40)
                      end
                      end
                      Shoes.debug("BBB  #{@link}")
                      Shoes.debug("COMB  #{(@link.nil? rescue true)}")
                      if(@link.nil? rescue true)
                      @final_flow.append do
                        @link = button "Reset Scheduler Time" , :width => '100%' , :margin => 5 do
                          minutes = (Integer(@repeating_hours.text) rescue false)
                          if not minutes or minutes < 1 or minutes > 3600
                            alert("Make sure to make proper entry is Minutes. Minutes can lie in 1 to 3600 (1 day): ") 
                          elsif not save_repeating_time(minutes * 60) 
                            alert("Make Sure To Save User Details before setting scheduler.")             
                          else
                            $showtimer = false
                            alert("The repeating time is now set to : #{minutes} minutes.")
                            $repeating_seconds = minutes * 60
                            $showtimer = true
                            attempt_login( @username.text , @password.text)
                            show_timer(app , 1 , 1)
                          end
                        end
                      end
                      end
              else
                      $showtimer = false
                      $repeating_seconds = -1
                      @para.remove
                      @para = nil
                      @repeating_hours.remove
                      @repeating_hours = nil
                      @link.remove
                      @link = nil
                      @time_elapsed.replace("")
                      unsave_repeating_time
              end
        end
    end
    @final_flow = flow :margin => 5 , :width => '100%' , :align => 'center' do
    end
    @timer_flow = flow :margin => 5 , :width => '100%' , :align => 'center' do
        @time_elapsed = para ""
    end    
    seconds = get_repeating_seconds.to_s rescue ""
    if not seconds.empty?
      @prefinal_flow.append do
         @para.remove rescue nil
         @para = para strong("Minutes") , :stroke => rgb(82,47,35)
         @repeating_hours.remove rescue nil
         @repeating_hours = edit_line(:width => 40)
         @repeating_hours.text = seconds.to_i / 60
      end
      @final_flow.append do
         seconds = seconds.to_i
         $repeating_seconds = seconds
      end
      $showtimer = true
      attempt_login( get_username , get_password)
      show_timer(app , 1 , 1)
      @final_flow.append do
          @link.remove rescue nil
          @link = button "Reset Scheduler Time" , :width => '100%' , :margin => 5 do
                minutes = (Integer(@repeating_hours.text) rescue false)
                if not minutes or minutes < 1 or minutes > 3600
                    alert("Make sure to make proper entry is Minutes. Minutes can lie in 1 to 3600 (1 day): ") 
                elsif not save_repeating_time(minutes * 60) 
                    alert("Make Sure To Save User Details before setting scheduler.")             
                else
                    $showtimer = false
                    alert("The repeating time is now set to : #{minutes} minutes.")
                    $repeating_seconds = minutes * 60
                    $showtimer = true
                    attempt_login( @username.text , @password.text)
                    show_timer(app , 1 , 1)
                end
          end
      end
      @checkbox.checked = true
    end
    @link_about = link("About").click do
         window :title => "About" , :width => 390, :height => 250 , :scroll => false , :resizable => false do
           background "#EFC".."AAD271"
           border( "AAD271".."#3D6919", strokewidth: 6)
          stack :margin => 20 , :align => "center" do
             title("About!" , :align => "center" , :size =>25)
             para("A cross platform cyberoam client developed by " , link("Harsh Trivedi" , :click =>  "http://github.com/HarshTrivedi") , " , (2012-2016) batch. \n Its a simple Ruby app built with Shoes toolkit. \n The App is open-sourced " , link("Here" , :click =>  "http://github.com/HarshTrivedi/AutoCyberoamLoginClient") , "\nPlease let me know in case of any bug or potential improvement!" , :align => "center" , :size => 10)
             button "OK!" , :margin_left => "40%" , :margin_right => "40%" , :width => "100%" do
                self.close
             end
          end
         end
    end 
    @link_help = link("Need Help?").click  do
         window :title => "Need Help?" , :width => 390, :height => 380 , :scroll => false , :resizable => false do
           background "#EFC".."AAD271"
           border( "AAD271".."#3D6919", strokewidth: 6)
           stack :margin => 20 , :align => "center" do
             title("Help?" , :align => "center" , :size => 25)
             para("Login/Logout are pretty obvious! \n Remember Details button stores your username and password in a hidden file in your machine, which will be used to load when you open the app next time. \n On checking Auto-login, it will keep on attempting to login at scheduled intervals. \n And unchecking it will stop the scheduler. \n On closing the app , the scheduler also stops. So make sure to minimize rather than closing unless needed. \n Time Elapsed show the time since the last login attenpt was made by scheduler." , :align => "left" , :size => 10)
             button "OK!" , :margin_left => "40%" , :margin_right => "40%" , :width => "100%" do
                self.close
             end
          end
         end
    end
    para( @link_about , " | " , @link_help , :align => 'center', :size => 10 ) 
  end

end
