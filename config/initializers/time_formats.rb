# RFC3339 format is used in Atom (http://tools.ietf.org/html/rfc4287)
# http://tools.ietf.org/html/rfc3339 (e.g. 2003-12-13T18:30:02Z)
Time::DATE_FORMATS[:rfc3339] = lambda { |time| time.utc.strftime("%Y-%m-%dT%H:%M:%SZ") }
