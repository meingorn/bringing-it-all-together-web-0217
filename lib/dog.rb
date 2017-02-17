require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(id: id=nil, name: name, breed: breed)
    @id = id
    @name =name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name)
    self.new_from_db(row.flatten)
  end

  def self.create(dog_att)
    dog = Dog.new(dog_att)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id)
    self.new_from_db(row.flatten)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      self.add_dog
    end
  end

  def add_dog
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    sql = <<-SQL
    SELECT id
    FROM dogs
    ORDER BY id
    DESC LIMIT 1
    SQL
    self.id = DB[:conn].execute(sql)[0][0]
    self
    end

end
