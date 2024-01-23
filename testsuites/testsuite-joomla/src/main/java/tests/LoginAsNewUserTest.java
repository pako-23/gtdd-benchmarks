package tests;

import static org.junit.Assert.assertEquals;
import po.BaseNavBar;
import po.ProfilePageInfo;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;
import utils.DriverProvider;
import utils.Properties;

public class LoginAsNewUserTest {

	private WebDriver driver;

	@Before
	public void setUp() {
		driver = DriverProvider.getInstance().getDriver();
		driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
		driver.get(Properties.app_url);
	}

	@Test
	public void testJoomlaLoginAsNewUser() throws Exception {
		String name = "Test User00";
		String username = "tuser00";
		String password = "tpassword";

		ProfilePageInfo profile = new BaseNavBar(driver)
				.authorLogin()
				.setUsername(username)
				.setPassword(password)
				.login();

		assertEquals(name, profile.getName());
		profile.standardUserLogOut();

	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
