package tests;


import static org.junit.Assert.assertTrue;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;


import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class AddMenuTest {

	private WebDriver driver;

    @Before
	public void setUp() {
    	driver = DriverProvider.getInstance().getDriver();
    	driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url +"/admin");
    }

	@Test
	public void testExpressCartAddMenu() throws Exception {
		driver.findElement(By.id("email")).sendKeys("owner@test.com");
		driver.findElement(By.id("password")).sendKeys("test");
		driver.findElement(By.id("loginForm")).click();
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[2]/li[2]/a")).click();
		driver.findElement(By.id("newNavMenu")).sendKeys("Test Menu");
		driver.findElement(By.id("newNavLink")).sendKeys("/category/tag000");
		driver.findElement(By.id("settings-menu-new")).click();
		Thread.sleep(6000);
		assertTrue(driver.findElement(By.xpath("/html/body/div[2]/div/main/div/div[2]/div[3]/div[4]/button")).isDisplayed());
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
