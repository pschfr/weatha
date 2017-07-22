# Global variables
units      = 'auto'
API_key    = '3dc48ab835ed1b4369c089d0e742ff03'
proxy_URL  = 'https://paulmakesthe.net/ba-simple-proxy.php?url='
darkSkyURL = 'https://api.darksky.net/forecast/' + API_key + '/'
directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
exclusions = 'hourly'
pittsburgh = '40.4406,-79.9959'

# Used for debugging
logging = false


# Attempt to geolocate user
geolocWeather = () ->
	if `('geolocation' in navigator)`
		navigator.geolocation.getCurrentPosition((position) ->
			getWeather(position.coords.latitude + ',' + position.coords.longitude)
			if logging
				console.log(position)
		, (error) ->
			getWeather(pittsburgh)
			if logging
				console.error(error)
		)
	else
		getWeather(pittsburgh)
	t = setTimeout(geolocWeather, 300000) # Every 5 min



# gets info from Dark Sky
getWeather = (location) ->
	xhr = new XMLHttpRequest()
	xhr.open('GET', proxy_URL + encodeURIComponent(darkSkyURL + location + '?units=' + units + '&exclude=' + exclusions), true)
	xhr.onreadystatechange = () ->
		if (xhr.readyState == 4 and xhr.status == 200)
				weather = JSON.parse(xhr.responseText).contents
				if logging
					console.log(weather)

				if not weather.currently.windBearing
					windDir = ''
				else
					windDir = directions[(Math.floor((weather.currently.windBearing / 22.5) + 0.5) % 16)]
					if weather.flags.units == 'us'
						windUnit = 'mph'
					else if weather.flags.units == 'si'
						windUnit = 'kph'

				renderIcons('currently', weather.currently.icon)
				document.getElementById('temp').innerHTML = Math.round(weather.currently.temperature) + '&deg;'
				if weather.minutely
					document.getElementById('conditions').innerHTML = weather.minutely.summary
				document.getElementById('wind').innerHTML = Math.round(weather.currently.windSpeed) + windUnit + ' ' + windDir
				document.getElementById('humidity').innerHTML = Math.round((weather.currently.humidity * 100)) + '%'
				document.getElementById('precip').innerHTML = Math.round((weather.currently.precipProbability * 100)) + '%'
				document.getElementById('daily').innerHTML = weather.daily.summary

				if weather.alerts
					if logging
						console.log(weather.alerts)
					document.getElementById('alerts').innerHTML = ''
					for alert, index in weather.alerts
						document.getElementById('alerts').innerHTML += '<a href="' + alert.uri + '" target="_blank" rel="noreferrer noopener" title="' + alert.description + '">' + alert.title + '</a>'
						if index > 0
							document.getElementById('alerts').innerHTML += '<br/>'

				# Loop over forecast info, adding icons into blank array for later usage
				dayIcons = []
				document.getElementById('forecast').innerHTML = ''
				for day, index in weather.daily.data
					if logging
						console.log(day)
					today = new Date(day.time * 1000)
					if day.precipProbability != 0
						precipText = Math.round((day.precipProbability * 100)) + '% ' + day.precipType
					else
						precipText = '0%'

					document.getElementById('forecast').innerHTML += '<div title="' + day.summary + '"><small>' + today.toString().split(' ').slice(0, 3).join(' ') + '</small><canvas id="day' + index + '" height="100" width="100"></canvas><p>' + Math.round(day.temperatureMax) + '&deg; &ndash; ' + Math.round(day.temperatureMin) + '&deg;</p><small>' + precipText + '</small></div>'

					dayIcons.push(['day' + index, day.icon])

				# Loop over icon array, drawing icons
				for icon in dayIcons
					renderIcons(icon[0], icon[1])

				fade()
	xhr.send(null)



# Render a new Skycon
renderIcons = (element, icon) ->
	skycons = new Skycons()
	skycons.set(element, icon)
	skycons.play()



# Render loading spinner
renderSpinner = () ->
	canvas = document.getElementById('spinner')
	context = canvas.getContext('2d')
	start = new Date()
	lines = 16
	cW = context.canvas.width
	cH = context.canvas.height

	draw = () ->
		rotation = parseInt(((new Date() - start) / 1000) * lines) / lines
		context.save()
		context.clearRect(0, 0, cW, cH)
		context.translate(cW / 2, cH / 2)
		context.rotate(Math.PI * 2 * rotation)
		for i in [0 .. lines]
			context.beginPath()
			context.rotate(Math.PI * 2 / lines)
			context.moveTo(cW / 10, 0)
			context.lineTo(cW / 4, 0)
			context.lineWidth = cW / 30
			context.strokeStyle = "rgba(255, 255, 255," + i / lines + ")"
			context.stroke()
		context.restore()
	window.setInterval(draw, 1000 / 30)



# Fade elements in
fade = () ->
	for fadedOut in document.getElementsByClassName('fadeout')
		fadedOut.style.opacity = 0
		fadedOut.style.display = 'none'
	for fadedIn in document.getElementsByClassName('fadein')
		fadedIn.style.opacity = 1



# Run everything
renderSpinner()
geolocWeather()
