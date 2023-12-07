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

public class LoginDeletedUserFailsTest {

	private WebDriver driver;

    @Before
	public void setUp() {
    	driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
    }

	@Test
	public void testExpressCartLoginUser() throws Exception {
		driver.get(Properties.app_url+"/admin");
		driver.findElement(By.id("email")).sendKeys("test000@test.com");
		driver.findElement(By.id("password")).sendKeys("password");
		driver.findElement(By.id("loginForm")).click();
		Thread.sleep(500);
		String text = driver.findElement(By.className("alert-danger")).getText();
		assertEquals("A user with that email does not exist.", text);
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
