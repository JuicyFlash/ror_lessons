# frozen_string_literal: true

require_relative 'train'
require_relative 'cargo_train'
require_relative 'passenger_train'
require_relative 'wagon'
require_relative 'passenger_wagon'
require_relative 'cargo_wagon'
require_relative 'station'
require_relative 'route'
# Управляющий класс для Station, Train, Route, Wagon
class Railroad
  attr_reader :trains
  # attr_reader :stations
  attr_reader :routes
  # attr_reader :wagons
  attr_reader :available_wagons_types

  def initialize
    @trains = []
    @stations = []
    @routes = []
    @wagons = []
    @available_wagons_types = [PassengerWagon, CargoWagon]
  end

  # Список типов вагонов
  def print_wagon_types
    @available_wagons_types.each do |wt|
      print_type =   'Грузовой' if wt == CargoWagon
      print_type =   'Пассажирский' if wt == PassengerWagon
      print_type ||= 'Не опредлён'
      print "#{@available_wagons_types.index(wt)}. #{print_type} "
    end
    puts
  end

  # Список вагонов
  def print_wagons
    puts 'Доступные вагоны: '
    @wagons.each do |wg|
      wagon_info(wg)
      puts
    end
  end

  def wagon_info(wg)
    wg_space_type =   'объёма' if wg.type == :cargo
    wg_space_type =   'мест' if wg.type == :passenger
    wg_space_type ||= 'не определено'
    hooked_print =    'в сотаве' if wg.hooked
    hooked_print =    'не в сотаве' unless wg.hooked
    hooked_print ||=  'не определено'
    print "Номер вагона #{@wagons.index(wg)}, тип #{wg.type_for_print}, доступно #{wg.available_space} #{wg_space_type}, занято #{wg.unavailable_space} #{wg_space_type}, #{hooked_print}"
  end

  def fill_wagon
    puts 'Выберите вагон:'
    print_wagons
    wg_idx = gets.chomp.to_i
    wg = @wagons[wg_idx]
    filled = false
    return if wg.nil?

    until filled
      begin
        case wg.type
        when :cargo
          puts 'Введите объём'
          volume = gets.chomp.to_i
          wg.fill_space(volume)
          puts 'Вагон заполнен'
          wagon_info(wg)
        when :passenger
          wg.fill_space
          puts 'Место в вагоне занято'
          wagon_info(wg)
        else
          puts 'Тип вагона не определён'
        end
        filled = true
      rescue RuntimeError => e
        puts e.message
      end
    end
  end

  # Добавление вагона
  def add_wagon
    puts
    print "Укажите типа вагона:   #{print_wagon_types} "
    wag_idx = gets.chomp.to_i
    if !@available_wagons_types[wag_idx].nil?
      created = false
      until created
        begin
          puts 'Укажите количество мест в вагоне' if @available_wagons_types[wag_idx] == PassengerWagon
          puts 'Укажите объём вагона' if @available_wagons_types[wag_idx] == CargoWagon
          wagon_param = gets.chomp
          wg = @available_wagons_types[wag_idx].new(wagon_param)
          @wagons << wg
          created = true
        rescue RuntimeError => e
          puts e.message
        end
      end
      puts 'Добавлен вагон: '
      wagon_info(wg)
      puts
    else
      puts 'Некорректно указан тип вагона'
    end
  end

  # Удаление вагона
  def remove_wagon
    print_wagons
    print 'Выберите вагон: '
    wag_idx = gets.chomp.to_i
    @wagons.delete(@wagons[wag_idx])
  end

  # Список всех станций - поездов - вагонов
  def report_stations
    @stations.each do |st|
      puts "Станция: #{st.name}"
      puts 'Поезда: '
      st.each_train do |tr|
        train_info(tr)
        print_train_wagons(@trains.index(tr))
      end
    end
  end

  # Список станций
  def print_stations
    puts 'Доступные станции: '
    @stations.each do |st|
      print "#{@stations.index(st)}.#{st.name} "
      puts
    end
  end

  # Добавление станции
  def add_station
    puts
    created = false
    until created
      print 'Введите название станции: '
      param_name = gets.chomp
      if @stations.map(&:name).include?(param_name)
        puts "Станция #{param_name} не добавлена - станция с таким названием уже есть"
      else
        begin
          @stations << Station.new(param_name)
          puts "Станция #{param_name} добавлена"
          created = true
        rescue RuntimeError => e
          puts e.message
        end
      end
    end
  end

  # Удаление станции
  def remove_station
    print_stations
    print 'Выберите станцию: '
    stat_idx = gets.chomp.to_i
    return if @stations[stat_idx].nil?

    puts "Станция удалена #{@stations[stat_idx].name}"
    @stations.delete(@stations[stat_idx])
  end

  def print_station_trains
    puts 'Выберите станцию'
    print_stations
    stat_idx = gets.chomp.to_i
    return if @stations[stat_idx].trains.nil?

    @stations[stat_idx].trains_by_type(:cargo).each do |tr|
      print "#{tr.number}  #{tr.print_type}"
      puts
    end
    @stations[stat_idx].trains_by_type(:passenger).each do |tr|
      print "#{tr.number}  #{tr.print_type}"
      puts
    end
  end

  # Добавление поезда
  def add_train
    created = false
    print 'Укажите типа поезда 0 - грузовой 1 - пассажирский: '
    param_type = gets.chomp.to_i
    puts
    until created
      print 'Задайте номер поезда: '
      param_number = gets.chomp
      case param_type
      when 0
        begin
          @trains << CargoTrain.new(param_number)
          created = true
          puts "Грузвой поезд #{param_number} создан"
        rescue RuntimeError => e
          puts e.message
        end
      when 1
        begin
          @trains << PassengerTrain.new(param_number)
          created = true
          puts "Пассажирский поезд #{param_number} создан"
        rescue RuntimeError => e
          puts e.message
        end
      else
        puts 'Некорректно указан тип поезда'
      end
    end
  end

  # Установка маршрута поезду
  def set_route_train
    puts 'Выберите поезд'
    print_trains
    train_idx = gets.chomp.to_i
    puts 'Выберите маршрут'
    print_routes
    route_idx = gets.chomp.to_i
    @trains[train_idx].set_route(@routes[route_idx]) unless @trains[train_idx].nil? && @routes[route_idx].nil?
  end

  # Перемещение поезда
  def move_train
    puts 'Выберите поезд'
    print_trains
    train_idx = gets.chomp.to_i
    puts '0 - переместить на предыдущую стануию 1 - переместить на следующую станцию'
    print_prev_train_station(train_idx)
    print_current_train_station(train_idx)
      .print_next_train_station(train_idx)
    puts
    param_move = gets.chomp.to_i
    return if @trains[train_idx].nil?

    case param_move
    when 0
      @trains[train_idx].move_prev_station
    when 1
      @trains[train_idx].move_next_station
    else
      'Команда не определена'
    end
    puts 'Поезд перемещён'
  end

  def train_info(tr)
    print "#{@trains.index(tr)}. Номер: #{tr.number}. Тип: #{tr.print_type}. Вагонов в составе: #{tr.wagons.length}"
  end

  # Список поездов
  def print_trains
    puts 'Доступные поезда: '
    @trains.each do |tr|
      train_info(tr)
      puts
      yield(tr) if block_given?
    end
  end

  # Отчёт по поездам - вагонам
  def trains_report
    print_trains { |tr| print_train_wagons(@trains.index(tr)) }
  end

  # Список вагонов поезда
  def print_train_wagons(train_idx)
    puts 'Вагоны: '
    @trains[train_idx].each_wagon do |wg|
      wagon_info(wg)
      puts
    end
  end

  def print_current_train_station(train_idx)
    puts "Текущая станция: #{@trains[train_idx].current_station.name}" unless @trains[train_idx].current_station.nil?
  end

  def print_next_train_station(train_idx)
    puts "Следующая станция: #{@trains[train_idx].next_station.name}" unless @trains[train_idx].next_station.nil?
  end

  def print_prev_train_station(train_idx)
    puts "Предыдущая станция: #{@trains[train_idx].prev_station.name}" unless @trains[train_idx].prev_station.nil?
  end

  # Удаление поезда
  def remove_train
    puts 'Выберите поезд для удаления'
    print_trains
    train_idx = gets.chomp.to_i
    return if @trains[train_idx].nil?

    puts "Поезд удалён #{@trains[train_idx].number}"
    @trains.delete(@trains[train_idx])
  end

  def edit_train_hook_wagon
    puts 'Выберите поезд'
    print_trains
    train_idx = gets.chomp.to_i
    puts 'Выберите вагон'
    print_wagons
    wagon_idx = gets.chomp.to_i
    @trains[train_idx].hook_wagon(@wagons[wagon_idx]) unless @trains[train_idx].nil? && @wagons[wagon_idx].nil?
  end

  def edit_train_unhook_wagon
    puts 'Выберите поезд'
    print_trains
    train_idx = gets.chomp.to_i
    puts 'Выберите вагон'
    print_train_wagons(train_idx)
    wagon_idx = gets.chomp.to_i
    @trains[train_idx].unhook_wagon(@wagons[wagon_idx]) unless @trains[train_idx].nil? && @wagons[wagon_idx].nil?
  end

  # Добавление маршрута
  def add_route
    puts 'Задайте начальную и конечную станцию маршрута'
    print_stations
    print 'Начальная станция:  '
    firs_idx = gets.chomp.to_i
    print 'Конечная станция:  '
    last_idx = gets.chomp.to_i
    return if @stations[firs_idx].nil? && @stations[last_idx].nil?

    @routes << Route.new(@stations[firs_idx], @stations[last_idx])
  end

  # Добавление станции в маршрут
  def edit_route_add_station
    puts 'Выберите маршрут'
    print_routes
    route_idx = gets.chomp.to_i
    puts 'Выберите станцию для добавления'
    print_stations
    station_idx = gets.chomp.to_i
    @routes[route_idx].add_station(@stations[station_idx]) unless @stations[station_idx].nil?
  end

  # Удаление станции из маршрута
  def edit_route_remove_station
    puts 'Выберите маршрут'
    print_routes
    route_idx = gets.chomp.to_i
    puts 'Выберите станцию для удаления'
    print_stations
    station_idx = gets.chomp.to_i
    @routes[route_idx].remove_station(@stations[station_idx]) unless @stations[station_idx].nil?
  end

  # Удаление маршрута
  def remove_route
    print_routes
    print 'Выберите маршрут: '
    route_idx = gets.chomp.to_i
    @routes.delete(@routes[route_idx])
  end

  # Список маршрутов
  def print_routes
    puts 'Доступные маршруты: '
    @routes.each do |rt|
      print "#{@routes.index(rt)}. "
      print " #{rt.print_stations}"
      puts
    end
  end

  def load_test_data
    @trains << CargoTrain.new('crg-1')
    @trains << CargoTrain.new('crg-2')
    @trains << CargoTrain.new('crg-3')
    @trains << PassengerTrain.new('pas-1')
    @trains << PassengerTrain.new('pas-2')
    @trains << PassengerTrain.new('pas-3')
    5.times do
      wg = CargoWagon.new('100')
      @wagons << wg
      @trains[1].hook_wagon(wg)
    end
  end
end
