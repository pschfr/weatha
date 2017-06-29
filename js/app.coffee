# Global variables
unit = 'imperial'
API_key = 'cb2555990c5309b5ffb90ba6fdea4c62'
proxy_URL = 'https://paulmakesthe.net/ba-simple-proxy.php?url='

# Attempt to geolocate user
geolocWeather = () ->
	if ('geolocation' in navigator) # I don't know if this works
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
			directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
			if weather.wind.deg is null
				windDeg = 0
				windDir = ''
			else
				windDeg = weather.wind.deg
				windDir = directions[(Math.floor((windDeg / 22.5) + 0.5) % 16)]
			humidity = weather.main.humidity

			document.getElementById('current').innerHTML = '<div><h1>' + temperature + '&deg;</h1><h3>' + condition + '</h3></div><p class="right">' + highTemp + '&deg; &ndash; ' + lowTemp + '&deg;<br/>Wind: ' + windSpeed + 'mph ' + windDir + '<br/>Humidity: ' + humidity + '%</p>'
			document.getElementById('location').innerHTML = location
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
				cond = day.weather[0].main
				date = day.dt_txt
				if (date.includes('12:00:00'))
					element.innerHTML += '<div><small>' + new Date(date).toString().split(' ').slice(0, 1) + '</small><h2>' + temp + '&deg;</h2><p>' + cond + '</p></div>'
					document.getElementsByTagName('main')[0].style.opacity = 1
	xhr.send(null)

geolocWeather()
