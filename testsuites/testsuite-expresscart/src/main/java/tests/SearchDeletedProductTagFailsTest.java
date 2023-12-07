package tests;


import static org.testng.AssertJUnit.assertEquals;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class SearchDeletedProductTagFailsTest {

	private WebDriver driver;

    @Before
	public void setUp() {
    	driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testExpressCartSearchDeletedProductTagFails() throws Exception {
		driver.findElement(By.id("frm_search")).sendKeys("tag000");
		driver.findElement(By.id("btn_search")).click();
		Thread.sleep(1000);
		assertEquals("No products found", driver.findElement(By.className("text-danger")).getText());
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
