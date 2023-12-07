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

public class OpenMenuTest {

	private WebDriver driver;

    @Before
	public void setUp() {
    	driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testExpressCartOpenMenu() throws Exception {
		driver.findElement(By.linkText("Test Menu")).click();
		assertEquals("NewProduct000", driver.findElement(By.xpath("//*[@id=\"container\"]/div/div[1]/div[2]/div/div/div/a/h3")).getText());
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
