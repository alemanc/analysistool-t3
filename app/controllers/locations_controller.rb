class LocationsController < ApplicationController
  def index
    # get all locations in the table locations
    @locations = Location.all

    # to json format
    @locations_json = @locations.to_json
  end

  def new
    # default: render ’new’ template (\app\views\locations\new.html.haml)
  end

  def create
    # create a new instance variable called @location that holds a Location object built from the data the user submitted
    @location = Location.new(params[:location])

    # if the object saves correctly to the database
    if @location.save
      # redirect the user to index
      redirect_to locations_path, notice: 'Location was successfully created.'
    else
      # redirect the user to the new method
      render action: 'new'
    end
  end

  def edit
    # find only the location that has the id defined in params[:id]
    @location = Location.find(params[:id])
  end

  def update
    # find only the location that has the id defined in params[:id]
    @location = Location.find(params[:id])

    # if the object saves correctly to the database
    if @location.update_attributes(params[:location])
      # redirect the user to index
      redirect_to locations_path, notice: 'Location was successfully updated.'
    else
      # redirect the user to the edit method
      render action: 'edit'
    end
  end

  def destroy
    # find only the location that has the id defined in params[:id]
    @location = Location.find(params[:id])

    # delete the location object and any child objects associated with it
    @location.destroy

    # redirect the user to index
    redirect_to locations_path, notice: 'Location was successfully deleted.'
  end

  def destroy_all
    # delete all location objects and any child objects associated with them
    Location.destroy_all

    # redirect the user to index
    redirect_to locations_path, notice: 'All locations were successfully deleted.'
  end

  def show
    # default: render ’show’ template (\app\views\locations\show.html.haml)
  end



  ##########################################################################################################
  ##########################################################################################################
  # INICIA CODIGO DE "RADIO"


  def distance(latitude1, longitude1, latitude2, longitude2)
    lat1 = latitude1
    lon1 = longitude1

    lat2 = latitude2
    lon2 = longitude2

    earth_radio = 6378.137

    dLat = (lat2 - lat1) * Math::PI / 180
    dLon = (lon2 - lon1) * Math::PI / 180


    a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(lat1 * Math::PI / 180 ) * Math.cos(lat2 * Math::PI / 180 ) * Math.sin(dLon/2) * Math.sin(dLon/2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    d = earth_radio * c;

    distance = d*1000
    distance

  end

  def inside?(latitude1, longitude1, latitude2, longitude2, radio)
    distance1 = distance(latitude1.to_f, longitude1.to_f, latitude2.to_f, longitude2.to_f)
    if distance1 < radio.to_f
      true
    else
      false
    end
  end

  def radio
    require 'json'

    # get all locations in the table locations
    @locations = Location.all

    # to json format
    @locations_json = @locations.to_json

    # obtencion de datos nuevos
    @lat = params[:lat]
    @lon = params[:lon]
    @rad = params[:rad]

    @lugares =  JSON.parse(@locations_json)

    n = @lugares.length
    i = 0
    while i<n
      loc = @lugares[i]
      puts loc["name"]
      inside = inside?( (loc["latitude"]), (loc["longitude"]), @lat, @lon, @rad )
      #puts inside
      (@lugares[i])["inside"] = inside
      i = i + 1
    end
    #@lugares = @lugares.to_json
    puts @lugares.inspect
    puts @locations_json

    #@x = Location.find(params[:x])
    @hello = 'hola mundo'
    @x = 2


    @prueba = 'saluda'
    puts 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
    puts ''
    puts ''
    puts ''
    puts ''
    puts ''
    puts ''
    puts ''
    puts @prueba + @lat
    puts @locations_json
    puts ''
    puts ''
    puts ''
    puts ''
    puts ''
    puts ''
    puts ''
    puts 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'

  end



  ##########################################################################################################
  ##########################################################################################################
  # INICIA CODIGO DE "CASCO CONVEXO"

  def transform_hullpoints( hullpoints )
    new_hull = Array.new
    aux = Array.new
    i = 0
    n = 0
    while i<hullpoints.length
      var = hullpoints[i]
      if n == 0
        aux = aux.push(var)
        n = n + 1
      elsif n == 1
        aux = aux.push(var)
        new_hull = new_hull.push(aux)
        aux = Array.new
        n = n - 1
      end
      i = i+1
    end
    return new_hull
  end

  def getHullPoints()
    if ( $hullPoints === nil )
      maxX = getMaxXPoint()
      minX = getMinXPoint()
      $hullPoints = quickHull( $inputPoints, minX, maxX ) + quickHull( $inputPoints, maxX, minX )
    end

    $hullPoints = transform_hullpoints($hullPoints)
    return $hullPoints
  end

  def getInputPoints()
    return $inputPoints
  end

  def getMaxXPoint()
    max = $inputPoints[0]
    $inputPoints.each do |p|
      if ( p[0] > max[0] )
        max = p
      end
    end
    return max
  end

  def getMinXPoint()
    min = $inputPoints[0]
    $inputPoints.each do |p|
      if ( p[0] < min[0] )
        min = p
      end
    end
    min
  end

  def calculateDistanceIndicator( start, end_fin, point )
    vLine = [end_fin[0] - start[0], end_fin[1] - start[1]]

    vPoint = [point[0] - start[0], point[1] - start[1]]


    distance_indicator = ( ( vPoint[1] * vLine[0] ) - ( vPoint[0] * vLine[1] ) )
    return distance_indicator
  end

  def getPointDistanceIndicators( start, end_fin, points )
    resultSet = Array.new

    points.each do |p|
      if ( ( distance = calculateDistanceIndicator( start, end_fin, p ) ) > 0 )
        resultSet.push( ['point'    => p, 'distance' => distance] )
      end
    end

    return resultSet
  end

  def getPointWithMaximumDistanceFromLine( pointDistanceSet )
    maxDistance = 0
    maxPoint    = nil

    pointDistanceSet.each do |p|
      p = p[0]
      if ( (p['distance']).to_f > maxDistance )
        maxDistance = p['distance']
        maxPoint    = p['point']
      end
    end

    return maxPoint
  end

  def getPointsFromPointDistanceSet( pointDistanceSet )
    points = Array.new

    pointDistanceSet.each do |p|
      p = p[0]
      points.push(p['point'])
    end

    return points
  end

  def quickHull( points, start, end_fin )
    pointsLeftOfLine = getPointDistanceIndicators( start, end_fin, points )
    newMaximalPoint = getPointWithMaximumDistanceFromLine( pointsLeftOfLine )

    if ( newMaximalPoint === nil )
      return end_fin
    end

    newPoints = getPointsFromPointDistanceSet( pointsLeftOfLine )
    merge = (quickHull( newPoints, start, newMaximalPoint )) + (quickHull( newPoints, newMaximalPoint, end_fin ))
    return merge

  end

  def get_locations_array()

    # get all locations in the table locations
    @locations = Location.all

    # to json format
    @locations_json = @locations.to_json
    @lugares =  JSON.parse(@locations_json)

    new_array = Array.new
    @lugares.each do |l|
      x = l["latitude"].to_f
      y = l["longitude"].to_f
      aux = Array.new
      aux = aux.push(x)
      aux = aux.push(y)
      new_array = new_array.push(aux)
    end

    return new_array
  end

  def get_hullObjects (hull_points)
    # get all locations in the table locations
    @locations = Location.all

    # to json format
    @locations_json = @locations.to_json
    @lugares =  JSON.parse(@locations_json)

    new_array = Array.new
    hull_points.each do |h|
      @lugares.each do |l|
        x = l["latitude"].to_f
        y = l["longitude"].to_f
        if h[0].to_f==x && h[1].to_f==y
          new_array = new_array.push(l)
        end
      end
    end
    return new_array
  end

  def distance_(locationA, locationB)
    lat1 = locationA[0]
    lon1 = locationA[1]

    lat2 = locationB[0]
    lon2 = locationB[1]

    earth_radio = 6378.137

    dLat = (lat2 - lat1) * Math::PI / 180
    dLon = (lon2 - lon1) * Math::PI / 180


    a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(lat1 * Math::PI / 180 ) * Math.cos(lat2 * Math::PI / 180 ) * Math.sin(dLon/2) * Math.sin(dLon/2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    d = earth_radio * c;

    distance = d*1000
    distance

  end

  def get_perimetro(hull_points)
    perimetro = 0

    i = 0
    while i < hull_points.length-1
      locationA = hull_points[i]
      locationB = hull_points[i+1]
      perimetro = perimetro + distance_(locationA, locationB)
      puts perimetro
      i = i + 1
    end

    perimetro = perimetro + distance_(hull_points[0], hull_points[(hull_points.length)-1])
    return perimetro
  end

  def casco
    $inputPoints =  get_locations_array
    $hullPoints = nil

    hull =  getHullPoints()
    @hullPoints = get_hullObjects(hull)
    puts @hullPoints.inspect

    @perimetro = get_perimetro(hull)
    @all_routes = Rails.application.routes.routes
    puts @all_routes.inspect
  end




  ##########################################################################################################
  ##########################################################################################################
  # INICIA CODIGO DE "UPLOAD RUTA CON UBICACIONES"




  def ruta
    uploaded_io = params[:file]
    @trayectoria =  JSON.parse(uploaded_io.read)
    @trayectoria = @trayectoria["route"]
    puts @trayectoria.inspect


    # get all locations in the table locations    =>   to json format
    @locations = Location.all
    @locations_json = @locations.to_json
    puts @locations_json.inspect
    @locations_json = JSON.parse(@locations_json)
    puts @locations_json.inspect

    @convergencia = Array.new
    @trayectoria.each do |tray|
      #puts tray["latitude"].to_f
      @locations_json.each do |loca|

        if tray["latitude"].to_f == loca["latitude"].to_f  &&  tray["longitude"].to_f == loca["longitude"].to_f
          @convergencia = @convergencia.push(loca)
        end
      end
    end
    #@convergencia = @convergencia.to_json
    puts @convergencia.inspect


  end

end
