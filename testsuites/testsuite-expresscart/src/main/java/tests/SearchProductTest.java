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

public class SearchProductTest {

	private WebDriver driver;

    @Before
	public void setUp() {
    	driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testExpressCartSearchProduct() throws Exception {
		driver.findElement(By.id("frm_search")).sendKeys("NewProduct000");
		driver.findElement(By.id("btn_search")).click();
		assertEquals("NewProduct000", driver.findElement(By.xpath("//*[@id=\"container\"]/div/div[1]/div[2]/div/div/div/a/h3")).getText());
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
