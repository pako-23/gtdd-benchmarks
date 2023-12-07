package tests;


import static org.junit.Assert.assertTrue;
import static org.testng.AssertJUnit.assertEquals;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import po.Home;

import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import utils.DriverProvider;
import utils.Properties;

public class AddReviewTest {

	private WebDriver driver;

    @Before
	public void setUp() {
    	driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testExpressCartAddReview() throws Exception {
		driver.findElement(By.xpath("//*[@id=\"navbarText\"]/ul/li[1]/a")).click();
		driver.findElement(By.id("email")).sendKeys("test@test.com");
		driver.findElement(By.id("password")).sendKeys("test");
		driver.findElement(By.id("customerloginForm")).click();
		driver.get(Properties.app_url);
		driver.findElement(By.linkText("Home")).click();
		new Home(driver).goToPage(1);
		driver.findElement(By.linkText("NewProduct000")).click();
		driver.findElement(By.id("add-review")).click();
		Thread.sleep(500);
		driver.findElement(By.id("review-title")).sendKeys("Review000");
		Thread.sleep(500);
		driver.findElement(By.id("review-description")).sendKeys("Description000");
		Thread.sleep(500);
		driver.findElement(By.id("review-rating")).sendKeys("5");
		Thread.sleep(500);
		driver.findElement(By.id("addReview")).click();
		Thread.sleep(1000);
		try {
			assertEquals("Review successfully submitted", driver.findElement(By.className("alert-success")).getText());
		} catch(Exception e) {
			Thread.sleep(6000);
			driver.navigate().refresh();
			assertTrue(driver.findElement(By.tagName("body")).getText().contains("Recent reviews"));
		}
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
