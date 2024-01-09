#!/bin/bash

JOURNAL_DIR="$HOME/.journal"
CONFIG_FILE="$JOURNAL_DIR/config.json"
JOURNALS_DIR="$JOURNAL_DIR/journals"
JOURNAL_SCRIPTS_DIR="$JOURNAL_DIR/scripts"
JOURNAL_TEMPLATES_DIR="$JOURNAL_DIR/templates"
SOURCE_TEMPLATES_DIR="./templates"

DEFAULT_MORNING_CRON="0 8 * * *"
DEFAULT_MIDDAY_CRON="0 12 * * *"
DEFAULT_EVENING_CRON="0 18 * * *"
DEFAULT_WEEKLY_CRON="0 18 * * 5"

echo "Journal Setup Configuration"

mkdir -p "$JOURNALS_DIR"
mkdir -p "$JOURNAL_TEMPLATES_DIR"
mkdir -p "$JOURNAL_SCRIPTS_DIR"

cp "./scripts/start_journal.sh" "$JOURNAL_SCRIPTS_DIR/start_journal.sh"
chmod +x "$JOURNAL_SCRIPTS_DIR/start_journal.sh"
cp "$SOURCE_TEMPLATES_DIR"/* "$JOURNAL_TEMPLATES_DIR"

echo "Journal templates copied to $JOURNAL_TEMPLATES_DIR."

setup_cron_job() {
	local cron_time=$1
	local template_file=$2
	local open_editor=$3
	local cron_command="bash $JOURNAL_DIR/scripts/start_journal.sh $JOURNAL_DIR $JOURNAL_TEMPLATES_DIR/$template_file $3 $EDITOR"

	# Adding job to crontab
	(
		crontab -l 2>/dev/null
		echo "$cron_time $cron_command"
	) | crontab -
	echo "Cron job set for $template_file"
}

setup_weekly_cron_job() {
	local cron_time=$1
	local template_file=$2
	local cron_command="bash $JOURNAL_DIR/scripts/weekly_journal.sh $JOURNAL_DIR $JOURNAL_TEMPLATES_DIR/$template_file $EDITOR"

	(
		crontab -l 2>/dev/null
		echo "$cron_time $cron_command"
	) | crontab -
	echo "Cron job set for weekly_journal.sh"
}

save_config() {
	echo "{\"morning_cron\":\"$MORNING_CRON\", \"midday_cron\":\"$MIDDAY_CRON\", \"evening_cron\":\"$EVENING_CRON\", \"weekly_cron\":\"$WEEKLY_CRON\"}" >"$CONFIG_FILE"
}

# Get cron job timings
read -p "Morning cron job timing [$DEFAULT_MORNING_CRON]: " MORNING_CRON
MORNING_CRON=${MORNING_CRON:-$DEFAULT_MORNING_CRON}

read -p "Midday cron job timing [$DEFAULT_MIDDAY_CRON]: " MIDDAY_CRON
MIDDAY_CRON=${MIDDAY_CRON:-$DEFAULT_MIDDAY_CRON}

read -p "Evening cron job timing [$DEFAULT_EVENING_CRON]: " EVENING_CRON
EVENING_CRON=${EVENING_CRON:-$DEFAULT_EVENING_CRON}

read -p "Weekly summary cron job timing [$DEFAULT_WEEKLY_CRON]: " WEEKLY_CRON
WEEKLY_CRON=${WEEKLY_CRON:-$DEFAULT_WEEKLY_CRON}

read -p "Editor to use [vim]: " EDITOR
EDITOR=${EDITOR:-vim}

# Save configuration to config.json
save_config

# Set up cron jobs
setup_cron_job "$MORNING_CRON" "morning_journal.md" "true"
setup_cron_job "$MIDDAY_CRON" "midday_journal.md" "true"
setup_cron_job "$EVENING_CRON" "evening_journal.md" "true"
setup_weekly_cron_job "$WEEKLY_CRON" "weekly_journal.md"

echo "Journal setup complete."

MORNING_HOUR=$(echo $MORNING_CRON | cut -d ' ' -f 2)
MIDDAY_HOUR=$(echo $MIDDAY_CRON | cut -d ' ' -f 2)
EVENING_HOUR=$(echo $EVENING_CRON | cut -d ' ' -f 2)

# Ask to create today's journal
read -p "Do you want to create today's journal now? (y/n): " create_journal_now

if [[ $create_journal_now == "y" ]]; then
	current_hour=$(date +%H)

	# Check if it's past morning time and before midday time
	if ((MORNING_HOUR <= current_hour)); then
		bash "$JOURNAL_SCRIPTS_DIR/start_journal.sh" "$JOURNAL_DIR" "$JOURNAL_TEMPLATES_DIR/morning_journal.md" "false"
	fi

	# Check if it's past midday time and before evening time
	if ((MIDDAY_HOUR <= current_hour)); then
		bash "$JOURNAL_SCRIPTS_DIR/start_journal.sh" "$JOURNAL_DIR" "$JOURNAL_TEMPLATES_DIR/midday_journal.md" "false"
	fi

	# Check if it's past evening time
	if ((EVENING_HOUR <= current_hour)); then
		bash "$JOURNAL_SCRIPTS_DIR/start_journal.sh" "$JOURNAL_DIR" "$JOURNAL_TEMPLATES_DIR/evening_journal.md" "false"
	fi

	$EDITOR "$JOURNALS_DIR/$(date +%Y-%m-%d).md"
fi
