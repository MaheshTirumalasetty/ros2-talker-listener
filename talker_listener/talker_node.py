import rclpy
from rclpy.node import Node
from std_msgs.msg import String

class TalkerNode(Node):
    def __init__(self):
        super().__init__('talker')
        self.publisher = self.create_publisher(String, 'chatter', 10)
        self.timer = self.create_timer(0.5, self.publish_message)
        self.count = 0

    def publish_message(self):
        msg = String()
        msg.data = 'Hello from ROS 2! Count: ' + str(self.count)
        self.publisher.publish(msg)
        self.get_logger().info('Publishing: ' + msg.data)
        self.count += 1

def main(args=None):
    rclpy.init(args=args)
    node = TalkerNode()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()