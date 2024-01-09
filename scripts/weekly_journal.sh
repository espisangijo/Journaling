#!/bin/bash

JOURNAL_DIR=$1
WEEKLY_TEMPLATE="$JOURNAL_DIR/templates/weekly_journal.md"

# Filename for weekly summary
CURRENT_WEEK=$(date +%Y-%W)
WEEKLY_SUMMARY_FILE="$JOURNAL_DIR/journals/Week-${CURRENT_WEEK}.md"

# Create or clear the weekly summary file
echo "---" >"$WEEKLY_SUMMARY_FILE"
echo "title: 'Weekly Summary - Week ${CURRENT_WEEK}'" >>"$WEEKLY_SUMMARY_FILE"
echo "date: 'Week of $(date -v-1d +%Y-%m-%d)'" >>"$WEEKLY_SUMMARY_FILE"
echo "---" >>"$WEEKLY_SUMMARY_FILE"

# Loop over the past 7 days to compile weekly summary
for i in {6..0}; do
	DAY=$(date -v-${i}d +%Y-%m-%d)
	DAY_FILE="$JOURNAL_DIR/journals/${DAY}.md"
	if [ -f "$DAY_FILE" ]; then
		echo -e "\n## Journal Entry: ${DAY}\n" >>"$WEEKLY_SUMMARY_FILE"
		# Extract and compile relevant sections from each day
		grep -E '## Unfinished Tasks|## Accomplishments|## Challenges/Learnings|## Gratitude' -A 3 "$DAY_FILE" >>"$WEEKLY_SUMMARY_FILE"
	fi
done

# Append the weekly template if it exists
if [ -f "$WEEKLY_TEMPLATE" ]; then
	cat "$WEEKLY_TEMPLATE" >>"$WEEKLY_SUMMARY_FILE"
fi
