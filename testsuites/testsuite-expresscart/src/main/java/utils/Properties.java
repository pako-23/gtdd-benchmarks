package utils;

import java.io.IOException;
import java.io.InputStream;

public class Properties {
    private static Properties ourInstance = new Properties();

    public static String home_dir = System.getProperty("user.home");
    public static String file_separator = System.getProperty("file.separator");
    public static String javaHome = System.getProperty("java.home");
    public static String user_dir = System.getProperty("user.dir");
    public static String app_url;
    private java.util.Properties appProps;
    private String appPropertiesPath;

    public static Properties getInstance() {
        return ourInstance;
    }

    private Properties() {
        try (InputStream fileInputStream = getClass().getResourceAsStream("/app.properties")) {
            this.appProps = new java.util.Properties();
            this.appProps.load(fileInputStream);
            this.loadAndCheckProperties();
            try{
                app_url = this.getProperty("app_url");
            } catch (NumberFormatException ex){
                throw new RuntimeException("Value " + this.getProperty("app_url") + " must be an url");
            }

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void loadAndCheckProperties(){
        String appURL = this.getProperty("app_url");
        this.checkPropertyNotEmpty(appURL);

        String headlessBrowser = this.getProperty("headless_browser");
        this.checkPropertyNotEmpty(headlessBrowser);
    }

    private void checkPropertyNotEmpty(String property){
        if(property.isEmpty()) throw new IllegalArgumentException("Property " + property + " cannot be empty");
    }

    public String getProperty(String propertyName){
        String envValue = System.getenv(propertyName);
        if (envValue != null) return envValue;

        String value = this.appProps.getProperty(propertyName);

        if(value == null)
            throw new IllegalStateException("getProperty: property with name " + propertyName + " does not exist in file " + this.appPropertiesPath);
        else
            return value;
    }

    public String getProperty(String propertyName, String defaultValue){
        return this.appProps.getProperty(propertyName, defaultValue);
    }

}
