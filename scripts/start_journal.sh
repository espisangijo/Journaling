#!/bin/bash

# Directory for journal entries
JOURNAL_DIR=$1

# Template file for the current entry
TEMPLATE_FILE=$2

OPEN_EDITOR=${3:-false}
EDITOR=${4:-vim}

WEEKLY_TEMPLATE="$JOURNAL_DIR/templates/weekly_template.md"

# Filename based on the current date
CURRENT_DATE=$(date +%Y-%m-%d)
JOURNAL_FILE="$JOURNAL_DIR/journals/${CURRENT_DATE}.md"

# Get yesterday's date and journal file
YESTERDAY_DATE=$(date -v-1d +%Y-%m-%d)
echo $YESTERDAY_DATE
YESTERDAY_JOURNAL_FILE="$JOURNAL_DIR/journals/${YESTERDAY_DATE}.md"

# Create a new journal file with the date if it doesn't exist
if [ ! -f "$JOURNAL_FILE" ]; then
	echo "---" >"$JOURNAL_FILE"
	echo "title: 'Journal Entry - ${CURRENT_DATE}'" >>"$JOURNAL_FILE"
	echo "date: '${CURRENT_DATE}'" >>"$JOURNAL_FILE"
	echo "---" >>"$JOURNAL_FILE"

	# If yesterday's journal file exists, append unchecked tasks
	if [ -f "$YESTERDAY_JOURNAL_FILE" ]; then
		echo -e "\n## Unfinished Tasks" >>"$JOURNAL_FILE"
		grep -E '^[[:space:]]*- \[ \]' "$YESTERDAY_JOURNAL_FILE" >>"$JOURNAL_FILE"
		echo -e "\n" >>"$JOURNAL_FILE"
	fi
fi

# Append the contents of the template to the journal file
cat "$TEMPLATE_FILE" >>"$JOURNAL_FILE"

if [ "$OPEN_EDITOR" = true ]; then
	# Open the journal file in the editor
	echo "Opening $JOURNAL_FILE in $EDITOR"
	$EDITOR "$JOURNAL_FILE"
fi
