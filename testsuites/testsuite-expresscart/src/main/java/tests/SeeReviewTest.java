package tests;


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

public class SeeReviewTest {

	private WebDriver driver;

    @Before
	public void setUp() {
    	driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testExpressCartSeeReview() throws Exception {

		driver.findElement(By.linkText("Home")).click();
		new Home(driver).goToPage(1);
		driver.findElement(By.linkText("NewProduct000")).click();
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/div/div[1]/div[2]/div/div[4]/a")).click();
		Thread.sleep(500);
		assertEquals("Rating: 5", driver.findElement(By.xpath("//*[@id=\"collapseReviews\"]/li/p[2]")).getText());
		assertEquals("Title: Review000", driver.findElement(By.xpath("//*[@id=\"collapseReviews\"]/li/p[3]")).getText());
		assertEquals("Description: Description000", driver.findElement(By.xpath("//*[@id=\"collapseReviews\"]/li/p[4]")).getText());
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
