package organizer

import (
	"encoding/json"
	"os"
	"path/filepath"
)

// GetSeriesChoicesPath returns the path to the series choices persistence file.
func (o *Organizer) GetSeriesChoicesPath() string {
	return filepath.Join(o.getConfigDir(), SeriesChoicesFileName)
}

// loadSeriesChoices reads previously saved series selections from disk.
func (o *Organizer) loadSeriesChoices() {
	data, err := os.ReadFile(o.GetSeriesChoicesPath())
	if err != nil {
		return // file doesn't exist yet — that's fine
	}
	if err := json.Unmarshal(data, &o.seriesChoices); err != nil {
		PrintYellow("⚠️  Warning: couldn't parse series choices file, starting fresh: %v", err)
		o.seriesChoices = make(map[string]string)
	}
}

// saveSeriesChoices writes the current series selections to disk immediately
// so a partial run still preserves choices made so far.
func (o *Organizer) saveSeriesChoices() {
	path := o.GetSeriesChoicesPath()
	data, err := json.MarshalIndent(o.seriesChoices, "", "  ")
	if err != nil {
		PrintYellow("⚠️  Warning: couldn't serialize series choices: %v", err)
		return
	}
	if err := os.WriteFile(path, data, 0644); err != nil {
		PrintYellow("⚠️  Warning: couldn't save series choices to %s: %v", path, err)
	}
}
