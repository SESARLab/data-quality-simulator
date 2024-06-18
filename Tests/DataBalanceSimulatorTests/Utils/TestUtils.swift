import Logging

public class TestUtils {
    public static func logParameterize(
        forFunction function: String, 
        withInput input: String, 
        logger: Logger
    ) {
        logger.debug("🧪 \(function)_\(input)")
    }
}