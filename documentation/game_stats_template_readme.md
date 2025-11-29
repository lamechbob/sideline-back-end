# Game Stats Sheet - Python Project

This project is designed to track detailed statistics for each play during games, including player actions, yards gained or lost, touchdowns, and safeties. The data helps evaluate player performance and analyze game flow. This project includes a Google Sheets-based tracking system for easy input and management.

---

## Table of Contents

- [Overview](#overview)
- [Key Sections & Columns](#key-sections--columns)
- [How to Use the Sheet](#how-to-use-the-sheet)
- [Data Validation Rules](#data-validation-rules)
- [Version Control](#version-control)
- [Tips for Accuracy](#tips-for-accuracy)
- [Troubleshooting](#troubleshooting)
- [Contact Information](#contact-information)
- [Future Enhancements](#future-enhancements)
- [Next Steps](#next-steps)

---

## Overview

This sheet tracks statistics for each play during the game, recording actions such as yards gained or lost, touchdowns, and safeties. It supports multiple players and actions per play, giving a comprehensive view of player performance.

---

## Key Sections & Columns

- **PlayID**: Unique identifier for each play. Enter a new number for each play, even if there are multiple actions associated with it.
- **Player Number**: The player’s jersey number or roster number for the play. Use the dropdown list from the **Roster** tab.
- **StatType**: The category of the statistic (Offense, Defense, Special Teams). This is selected from the dropdown list.
- **StatAction**: The specific action performed by the player (e.g., Pass, Tackle, Rush). Choose from the available options.
- **Yards**: The number of yards gained or lost on the play.
- **IsTD**: Checkbox to mark if the play resulted in a touchdown. (Checked = TRUE, Unchecked = FALSE)
- **IsSafety**: Checkbox to mark if the play resulted in a safety. (Checked = TRUE, Unchecked = FALSE)

---

## How to Use the Sheet

1. **Enter PlayID**: For each new play, input a unique **PlayID**. Increment the number for each new play.
2. **Select Player Number**: Choose the **Player Number** from the dropdown list that matches the player involved in the play.
3. **Choose StatType**: Select the relevant **StatType** (Offense, Defense, or Special Teams).
4. **Select StatAction**: Pick the specific **StatAction** from the dropdown list (e.g., Pass, Tackle).
5. **Enter Yards**: Input the number of **Yards** gained or lost.
6. **Mark IsTD and IsSafety**: Use the checkboxes to mark if the play resulted in a touchdown (**IsTD**) or a safety (**IsSafety**).

---

## Data Validation Rules

- **Player Number**: Must be selected from the list in the **Roster** tab.
- **Yards**: Must be a valid number, including negative numbers for losses (e.g., a sack or tackle for loss).
- **Play No**: Ensure **Play No** is sequential (no number can be less than the previous one).
- **IsTD and IsSafety**: Use checkboxes—checked = TRUE, unchecked = FALSE.

---

## Version Control

- **[MM/DD/YYYY]**: Added Player Number dropdown to improve consistency in data entry.
- **[MM/DD/YYYY]**: Implemented Play No validation to ensure proper ordering.
- **[MM/DD/YYYY]**: Clarified instructions on using the **Player Number** column for consistency.

---

## Tips for Accuracy

- Ensure **PlayID** is unique for every play and that no two rows share the same **PlayID**.
- **StatAction** should be consistent—ensure you select the correct action (e.g., "Pass" should not be written as "Throw").
- Avoid duplicating players for the same play. If a play has multiple actions (e.g., Pass and Catch), create a separate row for each action, but use the same **PlayID**.
- If you're unsure of any values (e.g., Yards, StatType), double-check with the game data to maintain consistency.

---

## Troubleshooting

- **Error: Play No is less than the previous one**: Make sure the Play No is entered in sequential order. If you're manually entering, always check the previous row to confirm.
- **Error: Invalid Player Number**: Make sure the Player Number exists in the **Roster** tab. If not, add the player to the **Roster** first.

---

## Contact Information

For questions or assistance with this sheet, please reach out to **[Your Name]** at **[Your Email]**.

---

## Future Enhancements

- **Upcoming Features**: We may add automated weekly summaries for player performance.
- **Possible Integrations**: Consider integrating data from other sources like wearable devices to track player performance in real-time.

---

## Next Steps:

1. **Fill out data for new games and plays** using the format outlined above.
2. **Review the Version Control** periodically for any changes or updates made to the sheet.

---

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
