package tests;

import static org.junit.Assert.assertEquals;
import static utils.Login.*;
import po.ManageUsersPage;
import org.junit.Before;
import org.junit.After;
import org.junit.Test;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;
import utils.DriverProvider;
import utils.Properties;

public class AddUserTest {

	private WebDriver driver;

	@Before
	public void setUp() {
		driver = DriverProvider.getInstance().getDriver();
		driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
		driver.get(Properties.app_url);
	}

	@Test
	public void testJoomlaAddUser() throws Exception {

		String name = "Test User00";
		String username = "tuser00";
		String password = "tpassword";
		String email = "testmail0@example.com";

		ManageUsersPage users = loginAsAdmin(driver)
				.siteAdmin()
				.setUsername("administrator")
				.setPassword("dodicicaratteri")
				.login()
				.users()
				.addUser()
				.setName(name)
				.setLoginName(username)
				.setPassword(password)
				.confirmPassword(password)
				.setEmail(email)
				.saveAndClose();

		assertEquals(name, users.getIthUserRealName(2));
		assertEquals(username, users.getIthUserName(2));
		assertEquals(email, users.getIthUserEmail(2));
		users.logout();

	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}
}
