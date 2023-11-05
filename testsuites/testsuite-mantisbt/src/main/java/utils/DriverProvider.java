package utils;

import io.github.bonigarcia.wdm.WebDriverManager;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;

import java.net.URL;

import java.util.logging.Level;
import java.util.logging.Logger;

public class DriverProvider {

    private static DriverProvider ourInstance = new DriverProvider();

    private DriverProvider(){
        WebDriverManager.chromedriver().clearDriverCache().setup();
        System.setProperty("webdriver.chrome.silentOutput", "true");
        Logger.getLogger("org.openqa.selenium.remote").setLevel(Level.OFF);
    }

    public WebDriver getDriver(){
        ChromeOptions chromeOptions = new ChromeOptions();
        if(Boolean.parseBoolean(Properties.getInstance().getProperty("headless_browser"))){
            chromeOptions.addArguments("--no-sandbox", "--headless", "--disable-gpu", "--window-size=1200x600");
        }


        try {
            URL driverURL = new URL(Properties.getInstance().getProperty("driver_url"));
            return new RemoteWebDriver(driverURL, DesiredCapabilities.chrome());
        } catch(Exception ex) {
            return new ChromeDriver(chromeOptions);
        }
    }

    public static DriverProvider getInstance(){
        return ourInstance;
    }
}
