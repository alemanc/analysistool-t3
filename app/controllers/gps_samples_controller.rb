class GpsSamplesController < ApplicationController

  def index

  end

  def create
    @gps_sample = GpsSample.new(params[:gps_sample])
    if @gps_sample.save
      redirect_to gps_samples_path, notice: 'The gps sample was successfully created.'
    else
      render action: 'new'
    end
  end

  def ruta



    uploaded_io = params[:file]
    file_name = (uploaded_io.original_filename).to_s
    aux = file_name.split(".")
    @usr_name = aux[0]

    ya_existe = false
    user_list =  GpsSample.uniq.pluck(:user_id)
    user_list.each do |punto|
      if punto == @usr_name
        ya_existe = true
      end
    end

    if !ya_existe

      puts '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
      @trayectoria =  JSON.parse(uploaded_io.read)

      @trayectoria["route"].each do |route|
        #puts "holita"
        #puts GpsSample.inspect
        query = GpsSample.new(:latitude => route['latitude'], :longitude => route['longitude'], :user_id => @usr_name, :timestamp => route['timestamp'])
        #query = GpsSample.delete_all
        #puts "hola"
        #puts query.inspect
        query.save
        #query.delete
        #puts "guardado"
      end
      #puts GpsSample.all.to_json

      #asd =  GpsSample.uniq.pluck(:user_id)
      #puts asd.inspect
      #qwe = GpsSample.pluck(:user_id)
      #puts qwe.inspect



    end

    # get all locations in the table GpsSample
    @locations = GpsSample.all

    @locations_json = GpsSample.find_all_by_user_id @usr_name
    @locations_json = @locations_json.to_json


  end




end