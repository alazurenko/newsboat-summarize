# newsboat-summarize

LLM-powered content summarization for newsboat RSS reader.

## INSTALL

```bash
./install.sh
```

## USAGE

1. Open newsboat
2. Navigate to article/video
3. Press `,m` to summarize
4. Browser opens with provider's chat
5. Paste content (Cmd+V/Ctrl+V)

## SUPPORTED

- Web articles (via curl/lynx)
- YouTube videos (transcript)
- AI providers: Claude, ChatGPT, Grok

## CONFIG

Edit `~/.newsboat/summarize.conf`:
```bash
PROVIDER="claude"     # claude, chatgpt, grok
BROWSER_CMD="open"    # browser command
CUSTOM_PROMPT="..."   # override default prompt
```

## DEPENDENCIES

- python3, pip
- youtube-transcript-api
- curl or lynx
- newsboat

## UNINSTALL

```bash
./uninstall.sh
```

## FILES

```
newsboat-summarize    # main script
summarize.conf       # configuration
install.sh           # installer
uninstall.sh         # uninstaller
```
