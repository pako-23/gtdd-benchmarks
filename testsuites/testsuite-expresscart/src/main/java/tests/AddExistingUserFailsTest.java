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

public class AddExistingUserFailsTest {

	private WebDriver driver;

    @Before
	public void setUp() {
    	driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
    }

	@Test
	public void testExpressCartNewUser() throws Exception {
		driver.get(Properties.app_url + "/admin");
		driver.findElement(By.id("email")).sendKeys("owner@test.com");
		driver.findElement(By.id("password")).sendKeys("test");
		driver.findElement(By.id("loginForm")).click();
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[1]/li[6]/a[2]")).click();
		driver.findElement(By.id("usersName")).sendKeys("TestUser000");
		driver.findElement(By.id("userEmail")).sendKeys("test000@test.com");
		driver.findElement(By.id("userPassword")).sendKeys("password");
		driver.findElement(By.xpath("//*[@id=\"userNewForm\"]/div[4]/input")).sendKeys("password");
		driver.findElement(By.id("btnUserAdd")).click();
		Thread.sleep(500);
		assertEquals("A user with that email address already exists", driver.findElement(By.className("alert-danger")).getText());
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[3]/li/a")).click();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
