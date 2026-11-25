module RadioBlacklist.Localization
import Codeware.Localization.*

/**
 * Texts for the Mod Settings page. Station names come from the game itself.
 */
public class RadioBlacklistLocalizationProvider extends ModLocalizationProvider {
    public func GetPackage(language: CName) -> ref<ModLocalizationPackage> {
        switch language {
            case n"en-us":
                return new RadioBlacklistEnglish();
            case n"ua-ua":
                return new RadioBlacklistUkrainian();
            case n"ru-ru":
                return new RadioBlacklistRussian();
            default:
                return null;
        }
    }

    public func GetFallback() -> CName {
        return n"en-us";
    }
}

public class RadioBlacklistEnglish extends ModLocalizationPackage {
    protected func DefineTexts() {
        this.Text("RadioBlacklist-Category", "Stations to skip");
        this.Text("RadioBlacklist-StationDescription", "Never play this station and hide it from the radio list. Turn off to hear it again.");
        this.Text("RadioBlacklist-Display", "Display");
        this.Text("RadioBlacklist-ShowNotice", "Show replacements on screen");
        this.Text("RadioBlacklist-ShowNoticeDescription", "Show a short notice when the mod switches a station or turns the radio off.");
        this.Text("RadioBlacklist-Debug", "Debug");
        this.Text("RadioBlacklist-DebugLog", "Debug log");
        this.Text("RadioBlacklist-DebugLogDescription", "Write what the mod does to the log.");
    }
}

public class RadioBlacklistUkrainian extends ModLocalizationPackage {
    protected func DefineTexts() {
        this.Text("RadioBlacklist-Category", "Пропускати станції");
        this.Text("RadioBlacklist-StationDescription", "Ніколи не вмикати цю станцію та сховати її зі списку радіо. Вимкніть, щоб знову її чути.");
        this.Text("RadioBlacklist-Display", "Відображення");
        this.Text("RadioBlacklist-ShowNotice", "Показувати заміни на екрані");
        this.Text("RadioBlacklist-ShowNoticeDescription", "Показувати коротке повідомлення, коли мод перемикає станцію або вимикає радіо.");
        this.Text("RadioBlacklist-Debug", "Налагодження");
        this.Text("RadioBlacklist-DebugLog", "Журнал налагодження");
        this.Text("RadioBlacklist-DebugLogDescription", "Записувати дії мода в журнал.");
    }
}

public class RadioBlacklistRussian extends ModLocalizationPackage {
    protected func DefineTexts() {
        this.Text("RadioBlacklist-Category", "Пропускать станции");
        this.Text("RadioBlacklist-StationDescription", "Никогда не включать эту станцию и скрыть её из списка радио. Выключите, чтобы снова её слышать.");
        this.Text("RadioBlacklist-Display", "Отображение");
        this.Text("RadioBlacklist-ShowNotice", "Показывать замены на экране");
        this.Text("RadioBlacklist-ShowNoticeDescription", "Показывать короткое сообщение, когда мод переключает станцию или выключает радио.");
        this.Text("RadioBlacklist-Debug", "Отладка");
        this.Text("RadioBlacklist-DebugLog", "Журнал отладки");
        this.Text("RadioBlacklist-DebugLogDescription", "Записывать действия мода в журнал.");
    }
}
