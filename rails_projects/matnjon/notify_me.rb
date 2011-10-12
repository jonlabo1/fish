require 'sinatra'
require 'sinatra/sequel'

set :product_name, 'Mat + Jon'
set :product_keywords, 'jewlery, retro, bracelets, cool'
set :placeholder_email, 'jonlabo@yahoo.com'
set :database, ENV['DATABASE_URL'] || 'sqlite://notify-me.db'
set :analytics_id, 'UA-26266908-1' #Just keep UA-XXXXX-X to not load analytics

migration "create subscriptions" do
  database.create_table :subscriptions do
    primary_key :id
    String      :email,      :null => false
    DateTime    :created_at, :null => false
  end
end

class Subscription < Sequel::Model
end

get '/' do
  erb :index
end

post '/subscribe' do
  if params[:email].empty?
    halt 'Email is required to subscribe!'
  end
  @email = params[:email]
  Subscription.insert(:email => @email, :created_at => DateTime.now) unless Subscription.find(:email => @email)
  erb :success
end

__END__

@@ layout
<!DOCTYPE html>
<html>
  <head>
    <meta content='<%= settings.product_name %>' name='description' />
    <meta content='<%= settings.product_keywords %>' name='keywords' />
    <title><%= "Notify me when #{settings.product_name} launches!" %></title>
    <link href='/reset.css' rel='stylesheet' />
    <link href='/notify-me.css' rel='stylesheet' />
    
  </head>
  <body>
    <div id='container'>
      <%= yield %>
    </div>
    <script src='https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js'></script>
    <script src='/notify-me.js'></script>
  <% if settings.analytics_id != 'UA-26266908-1' && settings.environment == :production %>    
    <script>
      var _gaq=[['_setAccount','<%= settings.analytics_id %>'],['_setDomainName', 'matnjon.com'],['_trackPageview']];
      (function(d,t){var g=d.createElement(t),s=d.getElementsByTagName(t)[0];g.async=1;
      g.src=('https:'==location.protocol?'//ssl':'//www')+'.google-analytics.com/ga.js';
      s.parentNode.insertBefore(g,s)}(document,'script'));
    </script>
  <% end %>
  </body>
</html>

@@ index
<div id='boxtop'></div>
<div id='banner'>
  <h1><%= "#{settings.product_name} will be launching soon!" %></h1>
</div>
<div id='boxmain'>
  <p>Enter your email address below and we'll notify you when it has launched.</p>
  <div id='subscribe'>
    <form action='/subscribe' method='post'>
      <label for='email'>Email</label>
      <input type='text' name='email' value='<%= settings.placeholder_email %>'></input>
      <div class='button-container'>
        <button value='submit' class='awesome'>Notify Me!</button>
      </div>
    </form>
  </div>
</div>

@@ success
<div id='boxtop'></div>
<div id='banner'>
  <h1>Thanks for your submission!</h1>
</div>
<div id='boxmain'>
  <h3><%= "We'll notify #{@email} when #{settings.product_name} launches!" %></h3>
  <div class='button-container'>
    <a href='/' class='awesome enabled'>Return Home</a>
  </div>
</div>