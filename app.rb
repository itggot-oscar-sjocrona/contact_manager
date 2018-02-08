class App < Sinatra::Base

	enable :sessions

	get('/') do
		slim(:home)
	end

	get('/register') do
		slim(:register)
	end

	get('/error') do
		slim(:error, locals:{error_msg:session[:error_msg], direction:session[:direction]})
	end

	get('/main') do
		slim(:main, locals:{user:session[:user]})
	end

	post('/login') do
		username = params["username"]
		password = params["password"]
		db = SQLite3::Database.new("contact_manager.sqlite")
		begin
			password_digest = db.execute("SELECT password FROM accounts WHERE username=?", [username]).join
			password_digest = BCrypt::Password.new(password_digest)
		rescue
			session[:error_msg] = "Login Error"
			session[:direction] = "/"
			redirect('/error')
		end

		if password_digest == password
			session[:user] = username
			redirect('/main')
		else
			session[:error_msg] = "Login Error"
			session[:direction] = "/"
			redirect('/error')
		end
	end

	post('/register') do
		username = params["username"]
		password1 = params["password1"]
		password2 = params["password2"]

		if password1 != password2
			session[:error_msg] = "Passwords doesn't match"
			session[:direction] = "/register"
			redirect('/error')
		end
		password = BCrypt::Password.create(password1)
		db = SQLite3::Database.new("contact_manager.sqlite")
		begin
			db.execute("INSERT INTO accounts (username,password) VALUES(?,?)", [username, password])
		rescue
			session[:error_msg] = "The username has already been taken"
			session[:direction] = "/register"
			redirect('/error')
		end
		redirect('/')
	end
end           
