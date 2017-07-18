# frozen_string_literal: true

require 'date'
require 'hb/cli'

module Hb
  # Habit provide a rich library to track the
  # progress of your habit.  
  class Habit
    attr_accessor :name
    attr_reader :progress

    # Class Methods
    class << self
      # Generate hash key for progress based
      # on date.
      #
      # Example
      #
      #   Habit.get_progress_key_from(Date.new(2017, 7, 18))
      #   # => :"2017,7"
      def get_progress_key_from(date)
        date.strftime('%Y,%-m').to_sym
      end

      # Initialize Habit object from string.
      #
      # string - The string to be parse.
      #
      # Example
      #
      #   Habit.initialize_from_string("workout\n2017,6:1001")
      #   # => #<Habit:0x007f9be6041b70 @name="workout",
      #   #    @progress={:"2017,6"=>"1001"}>
      #
      #   Habit.initialize_from_string("")
      #   # => nil
      def initialize_from_string(string)
        return nil if string.empty?
        arr = string.split("\n")
        habit_name = arr.shift
        hash = {}
        arr.each do |s|
          a = s.split(':')
          hash[a[0].to_sym] = a[1]
        end
        Habit.new(habit_name, hash)
      end
    end

    # Public APIs
    def initialize(name,
                   progress = {
                     Habit.get_progress_key_from(Date.today) => ' '
                   })
      @name = name
      @progress = progress
    end

    def name_length
      name.length
    end

    def latest_progress
      key = Habit.get_progress_key_from(Date.today)
      progress[key]
    end

    def done(done = true, date = Date.today)
      key = Habit.get_progress_key_from(date)
      initialize_progress_hash_from(key)
      update_progress_for(key, date.day, done)
    end

    def pretty_print_all
      @progress.map do |key, value|
        convert_key_to_date(key) + pretty_print_progress(value)
      end.join("\n")
    end

    def pretty_print_latest(no_of_space = 0)
      name.to_s + ' ' * no_of_space + ' : ' +
        pretty_print_progress(latest_progress)
    end

    def pretty_print_progress(progress_value)
      stat = progress_value.lstrip.split('').map do |x|
        x == '0' ? Hb::CLI.red('*') : Hb::CLI.green('*')
      end.join('')
      stat
    end

    def convert_key_to_date(key)
      key = key.to_s.split(',')
      "#{Date::MONTHNAMES[key[1].to_i]} #{key[0]}: "
    end

    def progress_output
      arr = @progress.map do |key, value|
        "#{key}:#{value}\n"
      end
      arr.join('')
    end

    def to_s
      "#{name}\n" + progress_output + "\n"
    end

    # Private APIs

    private

    def initialize_progress_hash_from(key)
      @progress[key] = ' ' unless @progress.key? key
    end

    def update_progress_for(key, day, done)
      i = day - @progress[key].length
      result = @progress[key].split('')
      i.times { result << '0' }
      result[day] = done ? '1' : '0'
      @progress[key] = result.join('')
    end
  end
end