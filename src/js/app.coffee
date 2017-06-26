# Global variables
unit = localStorage.getItem('temp-unit')
if unit == null
	unit = 'imperial'
API_key = 'cb2555990c5309b5ffb90ba6fdea4c62'

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

	xhr.open('GET', owm_URL, true)
	xhr.onreadystatechange = () ->
		if (xhr.readyState == 4 && xhr.status == 200)
			weather = JSON.parse(xhr.responseText)
			location = weather.name
			condition = weather.weather[0].description
			temperature = Math.round(weather.main.temp)
			windSpeed = Math.round(weather.wind.speed)
			windDeg = weather.wind.deg
			directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
			windDir = directions[(Math.floor((windDeg / 22.5) + 0.5) % 16)]
			humidity = weather.main.humidity

			document.getElementById('current').innerHTML = '<h3>' + temperature + '&deg;<br/> ' + condition + '</h3><p>' + windSpeed + 'mph ' + windDir + '<br/>' + humidity + '% humidity</p>'
			document.getElementById('location').innerHTML = location
			document.getElementById('location').style.opacity = 1
			console.log(weather)
	xhr.send(null)



# Fetch forecast from OpenWeatherMap
fetchForecast = (lat, lon) ->
	owm_URL = 'http://api.openweathermap.org/data/2.5/forecast?lat=' + lat + '&lon=' + lon + '&APPID=' + API_key + '&units=' + unit
	element = document.getElementById('forecast')
	xhr = new XMLHttpRequest()

	xhr.open('GET', owm_URL, true)
	xhr.onreadystatechange = () ->
		if (xhr.readyState == 4 && xhr.status == 200)
			element.innerHTML = ''
			for day in JSON.parse(xhr.responseText).list
				temp = Math.round(day.main.temp)
				date = day.dt_txt
				if (date.includes('12:00:00'))
					element.innerHTML += '<div class="day">' + temp + '&deg;<small>' + new Date(date).toString().split(' ').slice(0, 1) + ' ' + new Date(date).toString().split(' ').slice(1, 3).join(' ') + '</small></div>'
					console.log(day, temp, new Date(date))
					document.getElementById('weather').style.opacity = 1
	xhr.send(null)

geolocWeather()
