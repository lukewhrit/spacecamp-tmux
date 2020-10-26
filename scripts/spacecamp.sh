#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

get_tmux_option() {
  local option=$1
  local default_value=$2
  option_value="$(tmux show-option -gqv "$option")"
  local option_value

  if [ -z "$option_value" ]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}

main() {
  # set current directory variable
  current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

  # set configuration option variables
  show_battery=$(get_tmux_option "@spacecamp-show-battery" true)
  show_network=$(get_tmux_option "@spacecamp-show-network" true)
  show_flags=$(get_tmux_option "@spacecamp-show-flags" false)
  show_left_icon=$(get_tmux_option "@spacecamp-show-left-icon" smiley)
  show_timezone=$(get_tmux_option "@spacecamp-show-timezone" true)
  show_cpu_usage=$(get_tmux_option "@spacecamp-cpu-usage" false)
  show_ram_usage=$(get_tmux_option "@spacecamp-ram-usage" false)
  show_day_month=$(get_tmux_option "@spacecamp-day-month" false)
  show_time=$(get_tmux_option "@spacecamp-show-time" true)
  show_refresh=$(get_tmux_option "@spacecamp-refresh-rate" 5)

  # SpaceCamp Color Pallette
  white='#dedede'
  gray='#262626'
  dark_gray='#121212'
  cyan='#91aadf'
  green='#57ba37'
  orange='#f66100'
  red='#821a1a'
  pink='#cf73e6'
  yellow='#f0d50c'

  # Handle left icon configuration
  case $show_left_icon in
    smiley)  left_icon="☺ "            ;;
    session) left_icon="#S "           ;;
    window)  left_icon="#W "           ;;
    *)       left_icon=$show_left_icon ;;
  esac

  # Set timezone unless hidden by configuration
  case $show_timezone in
    false) timezone=""            ;;
    true)  timezone="#(date +%Z)" ;;
  esac

  case $show_flags in
    false)
      flags=""
      current_flags="";;
    true)
      flags="#{?window_flags,#[fg=${white}]#{window_flags},}"
      current_flags="#{?window_flags,#[fg=${white}]#{window_flags},}"
  esac

  # sets refresh interval to every 5 seconds
  tmux set-option -g status-interval "$show_refresh"

  # set length
  tmux set-option -g status-left-length 100
  tmux set-option -g status-right-length 100

  # message styling
  tmux set-option -g message-style "bg=${gray},fg=${white}"

  # status bar
  tmux set-option -g status-style "bg=${gray},fg=${white}"
  tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${yellow}],} ${left_icon}"
  tmux set-option -g status-right ""

  if $show_battery; then # battery
    tmux set-option -g status-right "#[fg=${dark_gray},bg=${pink}] #($current_dir/battery.sh) "
  fi

  if $show_ram_usage; then
    tmux set-option -ga status-right "#[fg=${white},bg=${red}] #($current_dir/ram_info.sh) "
  fi

  if $show_cpu_usage; then
    tmux set-option -ga status-right "#[fg=${dark_gray},bg=${orange}] #($current_dir/cpu_info.sh) "
  fi

  if $show_network; then # network
    tmux set-option -ga status-right "#[fg=${dark_gray},bg=${cyan}] #($current_dir/network.sh) "
  fi

  if $show_time; then
    if $show_day_month; then # only dd/mm
      tmux set-option -ga status-right "#[fg=${dark_gray},bg=${green}] %a %d/%m %I:%M %p ${timezone} "
    else
      tmux set-option -ga status-right "#[fg=${dark_gray},bg=${green}] %a %m/%d %I:%M %p ${timezone} "
    fi
  fi

  tmux set-window-option -g window-status-current-format "#[fg=${dark_gray},bg=${cyan}] #I #W${current_flags} "

  tmux set-window-option -g window-status-format "#[fg=${white}]#[bg=${gray}] #I #W${flags} "
  tmux set-window-option -g window-status-activity-style "bold"
  tmux set-window-option -g window-status-bell-style "bold"
}

# run main function
main
