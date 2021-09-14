# frozen_string_literal: true

if defined?(PryByebug)
  Pry.commands.alias_command "c", "continue"
  Pry.commands.alias_command "st", "step"
  Pry.commands.alias_command "n", "next"
  Pry.commands.alias_command "qp", "quit"
  Pry.commands.alias_command "q", "quit-program"
end

if defined?(Rails) && Rails.root
  def formatted_env
    Pry::Helpers::Text.green Rails.env
  end

  def app_name
    File.basename Rails.root
  end

  Pry.config.prompt = proc do |obj, nest_level, _|
    "[#{app_name}][#{formatted_env}] #{obj}:#{nest_level}> "
  end
end
