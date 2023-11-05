package tests;

import static org.junit.Assert.assertTrue;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import utils.BasePageObject;
import utils.DriverProvider;
import utils.Properties;

public class PasswordManagerSearchEntryNegativeTest {

	private WebDriver driver;
	private BasePageObject basePageObject;

	@Before
	public void setUp() throws Exception {
		driver = DriverProvider.getInstance().getDriver();
		driver.get(Properties.app_url);
		basePageObject = new BasePageObject(driver);
	}

	@Test
	public void testPasswordManagerSearchEntryNegative() throws Exception {
		driver.findElement(By.id("LoginForm_username")).clear();
		driver.findElement(By.id("LoginForm_username")).sendKeys("admin");
		driver.findElement(By.id("LoginForm_password")).clear();
		driver.findElement(By.id("LoginForm_password")).sendKeys("admin");
		driver.findElement(By.xpath("//*[@id='login-form']/div/div[2]/a")).click();
		driver.findElement(By.linkText("Advanced Search")).click();
		basePageObject.waitForElementBeingPresentOnPage(By.id("Entry_name"));
		basePageObject.sendKeys(By.id("Entry_name"), "NotAnEntry");
		basePageObject.click(By.name("yt0"));
		assertTrue(driver.findElement(By.className("empty")).getText().contains("No results found."));
		driver.findElement(By.linkText("Advanced Search")).click();
		basePageObject.waitForElementBeingPresentOnPage(By.id("Entry_name"));
		basePageObject.sendKeys(By.id("Entry_name"), "");
		basePageObject.sendKeys(By.id("Entry_username"), "");
		basePageObject.sendKeys(By.id("Entry_url"), "");
		basePageObject.sendKeys(By.id("Entry_tagList"), "");
		basePageObject.sendKeys(By.id("Entry_comment"), "");
		driver.findElement(By.linkText("Advanced Search")).click();
		basePageObject.waitForElementBeingInvisibleOnPage(By.id("Entry_username"));
		driver.findElement(By.linkText("Advanced Search")).click();
		basePageObject.waitForElementBeingPresentOnPage(By.id("Entry_username"));
		basePageObject.sendKeys(By.id("Entry_username"), "NotAnEntry@email.it");
		basePageObject.click(By.name("yt0"));
		assertTrue(driver.findElement(By.className("empty")).getText().contains("No results found."));
		driver.findElement(By.linkText("Advanced Search")).click();
		basePageObject.waitForElementBeingPresentOnPage(By.id("Entry_username"));
		basePageObject.sendKeys(By.id("Entry_name"), "");
		basePageObject.sendKeys(By.id("Entry_username"), "");
		basePageObject.sendKeys(By.id("Entry_url"), "");
		basePageObject.sendKeys(By.id("Entry_tagList"), "");
		basePageObject.sendKeys(By.id("Entry_comment"), "");
		driver.findElement(By.linkText("Advanced Search")).click();
		basePageObject.waitForElementBeingInvisibleOnPage(By.id("Entry_tagList"));
		driver.findElement(By.linkText("Advanced Search")).click();
		basePageObject.waitForElementBeingPresentOnPage(By.id("Entry_tagList"));
		basePageObject.sendKeys(By.id("Entry_tagList"), "NotAnEntry");
		basePageObject.click(By.name("yt0"));
		assertTrue(driver.findElement(By.className("empty")).getText().contains("No results found."));
		driver.findElement(By.linkText("Advanced Search")).click();
		basePageObject.waitForElementBeingPresentOnPage(By.id("Entry_name"));
		basePageObject.sendKeys(By.id("Entry_name"), "");
		basePageObject.sendKeys(By.id("Entry_username"), "");
		basePageObject.sendKeys(By.id("Entry_url"), "");
		basePageObject.sendKeys(By.id("Entry_tagList"), "");
		basePageObject.sendKeys(By.id("Entry_comment"), "");
		driver.findElement(By.linkText("Advanced Search")).click();
		basePageObject.waitForElementBeingInvisibleOnPage(By.id("Entry_url"));
		driver.findElement(By.linkText("Advanced Search")).click();
		basePageObject.waitForElementBeingPresentOnPage(By.id("Entry_url"));
		basePageObject.sendKeys(By.id("Entry_url"), "www.NotAnEntry.it");
		basePageObject.click(By.name("yt0"));
		assertTrue(driver.findElement(By.className("empty")).getText().contains("No results found."));
		driver.findElement(By.linkText("Advanced Search")).click();
		basePageObject.waitForElementBeingPresentOnPage(By.id("Entry_name"));
		basePageObject.sendKeys(By.id("Entry_name"), "");
		basePageObject.sendKeys(By.id("Entry_username"), "");
		basePageObject.sendKeys(By.id("Entry_url"), "");
		basePageObject.sendKeys(By.id("Entry_tagList"), "");
		basePageObject.sendKeys(By.id("Entry_comment"), "");
		driver.findElement(By.linkText("Advanced Search")).click();
		basePageObject.waitForElementBeingInvisibleOnPage(By.id("Entry_comment"));
		driver.findElement(By.linkText("Advanced Search")).click();
		basePageObject.waitForElementBeingPresentOnPage(By.id("Entry_comment"));
		basePageObject.sendKeys(By.id("Entry_comment"), "NotAnEntry");
		basePageObject.click(By.name("yt0"));
		assertTrue(driver.findElement(By.className("empty")).getText().contains("No results found."));
		driver.findElement(By.linkText("Profile")).click();
		driver.findElement(By.linkText("Logout")).click();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}
	
	public WebDriver getDriver() {
		return driver;
	}


}
