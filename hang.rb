#!/usr/bin/env ruby

require 'yaml'

class Game
  # hangman game class - word generation, answer checking, victory conditions, screen refresh, main loop
  attr_reader :word, :feedback
  attr_accessor :tries_left

  def initialize
    system("clear")
    @word = get_random_line
    @tries_left = 10
    @feedback = Array.new(@word.length).map{"_"}  # creates an array with the same length as the word to guess and fills it with _'s
    @game_running = true
    @game_win = false
    @errmsg = nil
  end

  def save_game
    savegame = self.to_yaml
    File.open('save.hang', 'w') do |f|
      f << savegame
    end
  end

  def load_game
    savegame = YAML::load(File.read('save.hang'))
    return savegame
  end

  def get_random_line
    chosen_line = nil
    File.foreach('words.txt').each_with_index do |x,i|
      chosen_line = x if x.chomp.strip.length.between?(5,12) && rand < 1.0/(i+1)
    end
    return chosen_line.strip.chomp.downcase
  end

  def get_guess
    puts "Enter your guess ( one letter only ) // \"SAVE\" to save!"
    guess = gets.chomp.scan(/\w/).join
    if guess == "SAVE"
      save_game
      return "SAVE"
    else
      return guess.chomp.strip.downcase[0]
    end
  end

  def check_guess(guess)
    guess_result = true   # required for tries_left to not decrement
    if !guess
      @errmsg = "Please input a character!"
    elsif guess == "SAVE"
      @errmsg = "SAVED!"
    else
      word_chars = @word.split('')
      guess_result = false

      word_chars.each_with_index do |x,i|
        # if the guess is the same as the currently checked character, add it to the feedback array
        if x == guess
          @feedback[i] = x
          @word[i] = " "
          guess_result = true
        end
      end
    end
    return guess_result
  end

  def check_win
    unless @feedback.include?("_")
      @game_running = false
      @game_win = true
      @errmsg = "You win!"
    end
  end

  def update_display
    system("clear")
    puts "Remaining tries: #{tries_left}"
    puts @feedback.join('')
    # --------------------
    puts @errmsg if @errmsg
  end

  def main_loop
    loop do
      update_display
      yield
      check_win
    end
  end
end

# --------------------------- #
#    GAME MAIN LOOP LOGIC     #
# --------------------------- #

hang = Game.new
puts "Load saved game? y/N"
load_choice = gets.chomp.strip.downcase
hang = hang.load_game if load_choice == "y"

hang.main_loop do
  guess = hang.get_guess
  guess_result = hang.check_guess(guess)
  hang.tries_left -= 1 unless guess_result
end
