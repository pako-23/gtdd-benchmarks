package main;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.runners.Suite.SuiteClasses;

public class Main {

    private static List<String> getTestSuite() {
        SuiteClasses ann = TestSuite.class.getAnnotation(SuiteClasses.class);
        return Arrays.stream(ann.value())
            .map(c -> c.getName())
            .collect(Collectors.toList());
    }

    private static Class<?>[] getTests(final String[] args) {
        final List<String> testNames =
            args.length == 0 ? getTestSuite() : Arrays.asList(args);

        final Class<?>[] tests = new Class<?>[testNames.size()];

        try {
            for (int i = 0; i < tests.length; ++i)
                tests[i] = Class.forName(testNames.get(i));
        } catch(ClassNotFoundException ex) {
            System.err.println(ex.toString());
            System.exit(1);
        }

        return tests;
    }

    public static void main(final String[] args) {
        if (args.length > 0 && Arrays.asList(args).contains("--list-tests")) {
            getTestSuite().forEach(System.out::println);
            System.exit(0);
        }

        final Class<?>[] tests = getTests(args);
        final boolean[] results = new boolean[tests.length];

        for (int i = 0; i < tests.length; ++i) {
            final Result result = JUnitCore.runClasses(tests[i]);
            if (!result.wasSuccessful()) {
                result.getFailures().stream().forEach(System.out::println);
                break;
            }
            results[i] = true;
        }

        for (int i = 0; i < tests.length; ++i) {
            final String testName = tests[i].getName();
            System.out.println(String.format("%s %d", testName, results[i] ? 1 : 0));
        }

        System.exit(0);
    }
}
