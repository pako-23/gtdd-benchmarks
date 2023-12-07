package tests;

import static org.junit.Assert.assertFalse;
import static utils.Login.*;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import po.ManageUsersPage;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class DeleteUserTest {

	private WebDriver driver;

    @Before
	public void setUp() {
        driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testJoomlaDeleteUser() throws Exception {
		String user = "Test User00";

		ManageUsersPage users = loginAsAdmin(driver)
				.siteAdmin()
				.setUsername("administrator")
				.setPassword("dodicicaratteri")
				.login()
				.users()
				.selectSecondUser()
				.deleteSelectedUser();

		assertFalse(users.containsUser(user));
		users.logout();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
