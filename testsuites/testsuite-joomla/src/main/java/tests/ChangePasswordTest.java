package tests;


import static org.testng.AssertJUnit.assertEquals;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import po.BaseNavBar;
import po.EditProfilePage;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class ChangePasswordTest {

	private WebDriver driver;

    @Before
	public void setUp() {
        driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testJoomlaChangePassword() throws Exception {
		String username = "tuser00";
		String oldPassword = "tpassword";
		String password = "newpassowrd01";

		EditProfilePage profile = new BaseNavBar(driver)
				.authorLogin()
				.setUsername(username)
				.setPassword(oldPassword)
				.login()
				.editProfile()
				.setPassword(password)
				.confirmPassword(password)
				.submit();

		assertEquals("Profile saved.", profile.getAlertMessage());
		profile.standardUserLogOut();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
