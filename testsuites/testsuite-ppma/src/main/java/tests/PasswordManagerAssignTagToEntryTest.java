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

public class PasswordManagerAssignTagToEntryTest {

	private WebDriver driver;
	private BasePageObject basePageObject;

	@Before
	public void setUp() throws Exception {
		driver = DriverProvider.getInstance().getDriver();
		driver.get(Properties.app_url);
		basePageObject = new BasePageObject(driver);
	}

	@Test
	public void testPasswordManagerAssignTagToEntry() throws Exception {
		driver.findElement(By.id("LoginForm_username")).clear();
		driver.findElement(By.id("LoginForm_username")).sendKeys("admin");
		driver.findElement(By.id("LoginForm_password")).clear();
		driver.findElement(By.id("LoginForm_password")).sendKeys("admin");
		driver.findElement(By.xpath("//*[@id='login-form']/div/div[2]/a")).click();
		basePageObject.mouseOver(By.linkText("Entries"));
		driver.findElement(By.linkText("Create")).click();
		basePageObject.waitForElementBeingPresentOnPage(By.id("Entry_name"));
		basePageObject.sendKeys(By.id("Entry_name"), "Facebook");
		basePageObject.sendKeys(By.id("Entry_username"), "myusername@email.it");
		basePageObject.sendKeys(By.id("Entry_password"), "mypassword");
		basePageObject.sendKeys(By.id("Entry_tagList"), "");
		basePageObject.sendKeys(By.id("Entry_url"), "www.facebook.it");
		basePageObject.sendKeys(By.id("Entry_comment"), "My Facebook Page");
		basePageObject.click(By.name("yt0"));
		assertTrue(driver.findElement(By.xpath("html/body/div[1]/div/div/div[4]/table/tbody/tr/td[3]")).getText().contains(""));
		driver.navigate().refresh();
		basePageObject.mouseOver(By.linkText("Tags"));
		driver.findElement(By.linkText("Create")).click();
		driver.findElement(By.id("Tag_name")).clear();
		driver.findElement(By.id("Tag_name")).sendKeys("Facebook");
		driver.findElement(By.name("yt0")).click();
		assertTrue(driver.findElement(By.xpath("html/body/div[1]/div/div/div[4]/table/tbody/tr/td[2]")).getText().contains("0"));
		driver.navigate().refresh();
		driver.findElement(By.linkText("Entries")).click();
		driver.findElement(By.xpath("html/body/div[1]/div/div/div[3]/table/tbody/tr/td[4]/a[4]")).click();
		basePageObject.waitForElementBeingPresentOnPage(By.xpath("(//input[@id='Entry_tagList'])[2]"));
		basePageObject.sendKeys(By.xpath("(//input[@id='Entry_tagList'])[2]"), "Facebook");
		basePageObject.click(By.name("yt1"));
		assertTrue(driver.findElement(By.xpath("html/body/div[1]/div/div/div[4]/table/tbody/tr/td[3]")).getText().contains("Facebook"));
		driver.navigate().refresh();
		driver.findElement(By.linkText("Tags")).click();
		assertTrue(driver.findElement(By.xpath("html/body/div[1]/div/div/div[3]/table/tbody/tr/td[2]")).getText().contains("1"));
		driver.findElement(By.xpath("html/body/div[1]/div/div/div[3]/table/tbody/tr/td[3]/a[2]")).click();
		driver.findElement(By.name("yt0")).click();
		driver.navigate().refresh();
		driver.findElement(By.linkText("Entries")).click();
		assertTrue(driver.findElement(By.xpath("html/body/div[1]/div/div/div[3]/table/tbody/tr/td[3]")).getText().contains("Facebook"));
		driver.findElement(By.xpath("html/body/div[1]/div/div/div[3]/table/tbody/tr/td[4]/a[5]")).click();
		driver.switchTo().alert().accept();
		driver.navigate().refresh();
		driver.findElement(By.linkText("Profile")).click();
		driver.findElement(By.linkText("Logout")).click();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
