#Класс Station (Станция):
#Имеет название, которое указывается при ее создании
#Может принимать поезда (по одному за раз)
#Может возвращать список всех поездов на станции, находящиеся в текущий момент
#Может возвращать список поездов на станции по типу (см. ниже): кол-во грузовых, пассажирских
#Может отправлять поезда (по одному за раз, при этом, поезд удаляется из списка поездов, находящихся на станции).
class Station
  attr_reader :name
  attr_reader :trains
  
  def initialize (name)
    @name = name
    @trains = []
  end
  
  def recive_train (train)
    @trains << train
  end
  
  def trains_by_type (train_type)
   @trains.select{|train| train.type == train_type}
  end
  
  def send_train (train)
    @trains.delete(train)
  end
end
