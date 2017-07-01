# Global variables
unit = 'imperial'
API_key = 'cb2555990c5309b5ffb90ba6fdea4c62'
proxy_URL = 'https://paulmakesthe.net/ba-simple-proxy.php?url='
directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
icons_list = ['clear-day', 'clear-night', 'partly-cloudy-day', 'partly-cloudy-night', 'cloudy', 'rain', 'sleet', 'snow', 'wind', 'fog']



# Attempt to geolocate user
geolocWeather = () ->
	if `('geolocation' in navigator)`
		navigator.geolocation.getCurrentPosition((position) ->
			fetchWeather(position.coords.latitude, position.coords.longitude)
			fetchForecast(position.coords.latitude, position.coords.longitude)
		)
	else
		fetchWeather('40.4406', '-79.9959')
		fetchForecast('40.4406', '-79.9959')
	t = setTimeout(geolocWeather, 300000) # Every 5 min



# Fetch weather from OpenWeatherMap
fetchWeather = (lat, lon) ->
	owm_URL = 'http://api.openweathermap.org/data/2.5/weather?lat=' + lat + '&lon=' + lon + '&APPID=' + API_key + '&units=' + unit
	xhr = new XMLHttpRequest()

	xhr.open('GET', proxy_URL + encodeURIComponent(owm_URL), true)
	xhr.onreadystatechange = () ->
		if (xhr.readyState == 4 && xhr.status == 200)
			weather = JSON.parse(xhr.responseText).contents
			location = weather.name
			condition = weather.weather[0].description
			temperature = Math.round(weather.main.temp)
			highTemp = Math.round(weather.main.temp_max)
			lowTemp = Math.round(weather.main.temp_min)
			windSpeed = Math.round(weather.wind.speed)
			if weather.wind.deg is null
				windDeg = 0
				windDir = ''
			else
				windDeg = weather.wind.deg
				windDir = directions[(Math.floor((windDeg / 22.5) + 0.5) % 16)]
			humidity = weather.main.humidity

			document.getElementById('temp').innerHTML = temperature + '&deg;'
			document.getElementById('conditions').innerHTML = condition
			document.getElementById('highlow').innerHTML =  highTemp + '&deg; &ndash; ' + lowTemp + '&deg;'
			document.getElementById('wind').innerHTML = windSpeed + 'mph ' + windDir
			document.getElementById('humidity').innerHTML = humidity + '%'
			document.getElementById('location').innerHTML = location

			icon = switch
				when weather.weather[0].main = 'Clouds' then icons_list[4]
				when weather.weather[0].main = 'Clear' then icons_list[0]
				when weather.weather[0].main = 'Atmosphere' then icons_list[9]
				when weather.weather[0].main = 'Snow' then icons_list[7]
				when weather.weather[0].main = 'Rain' then icons_list[5]
				when weather.weather[0].main = 'Drizzle', 'Thunderstorm' then icons_list[6]
				else icon = icons_list[0]

			renderIcons('currently', icon)
	xhr.send(null)



# Fetch forecast from OpenWeatherMap
fetchForecast = (lat, lon) ->
	owm_URL = 'http://api.openweathermap.org/data/2.5/forecast?lat=' + lat + '&lon=' + lon + '&APPID=' + API_key + '&units=' + unit
	element = document.getElementById('forecast')
	xhr = new XMLHttpRequest()

	xhr.open('GET', proxy_URL + encodeURIComponent(owm_URL), true)
	xhr.onreadystatechange = () ->
		if (xhr.readyState == 4 && xhr.status == 200)
			element.innerHTML = ''
			for day in JSON.parse(xhr.responseText).contents.list
				temp = Math.round(day.main.temp)
				cond = day.weather[0].description
				date = day.dt_txt.replace(/-/g, "/")
				if (date.includes('12:00:00'))
					element.innerHTML += '<div><small>' + new Date(date).toString().split(' ').slice(0, 1) + '</small><h2>' + temp + '&deg;</h2><p>' + cond + '</p></div>'
					document.getElementsByTagName('main')[0].style.opacity = 1
	xhr.send(null)



# Render a new Skycon
renderIcons = (element, icon) ->
	skycons = new Skycons({
		'color': 'white',
		'resizeClear': true
	})
	skycons.add(element, icon)
	skycons.play()



# Run everything
geolocWeather()
