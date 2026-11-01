"""In-memory note store."""

NOTES: dict[int, str] = {}


def add(text: str) -> int:
    note_id = len(NOTES) + 1
    NOTES[note_id] = text
    return note_id
