# newsboat-summarize

LLM-powered content summarization for [newsboat RSS reader](https://github.com/newsboat/newsboat).

## Install

```bash
./install.sh
```

## Usage

1. Open newsboat
2. Navigate to article/video
3. Press `,m` to summarize
4. Browser opens with LMM provider's chat
5. Paste content (Cmd+V/Ctrl+V)

## Supported

- Web articles (via curl/lynx)
- YouTube videos (transcript)
- AI providers: Claude, ChatGPT, Grok

## Config

Edit `~/.newsboat/summarize.conf`:
```bash
PROVIDER="claude"     # claude, chatgpt, grok
BROWSER_CMD="open"    # browser command
CUSTOM_PROMPT="..."   # override default prompt
```

## Dependencies

- python3, pip
- youtube-transcript-api
- curl or lynx
- newsboat

## Uninstall

```bash
./uninstall.sh
```

## Files

```
newsboat-summarize    # main script
summarize.conf       # configuration
install.sh           # installer
uninstall.sh         # uninstaller
```
## License

[MIT](https://opensource.org/license/MIT)
