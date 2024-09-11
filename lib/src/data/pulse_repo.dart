import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:multicast_dns/multicast_dns.dart';

class PulseRepo {
  String esp32Url = '';

  Future<bool> discoverEsp32(String esp32Hostname) async {
    print('=========== Entered 1 ===================');
    final MDnsClient mdns = MDnsClient(rawDatagramSocketFactory:
        (dynamic host, int port,
            {bool? reuseAddress, bool? reusePort, int? ttl}) {
      print('=========== Entered 2 ===================');
      return RawDatagramSocket.bind(host, port,
          reuseAddress: true, reusePort: false, ttl: ttl!);
    });
    print('=========== Entered 3 ===================');
    await mdns.start();
    print('=========== Entered 4 ===================');

    try {
      print('=========== Entered 5 ===================');
      // Look for a service matching '_http._tcp.local'
      await for (PtrResourceRecord ptr in mdns.lookup<PtrResourceRecord>(
          ResourceRecordQuery.serverPointer(esp32Hostname))) {
        // Look for the matching service details.

        print('=========== Entered 6 ===================');
        await for (SrvResourceRecord srv in mdns.lookup<SrvResourceRecord>(
            ResourceRecordQuery.service(ptr.domainName))) {
          print('Found service: ${srv.target}');
          esp32Url = 'http://${srv.target}.local:${srv.port}';
          print(esp32Url);

          break;
        }
        print('=========== Entered 7 ===================');
      }
      print('=========== Entered 8 ===================');
    } catch (e) {
      print('=========== Entered 9 ===================');
      print(e);
    } finally {
      print('=========== Entered 10 ===================');
      // Finally still runs even if there is a return statement in the try-catch
      mdns.stop();
    }
    return esp32Url.isNotEmpty ? true : false;
  }

  Future<Map<String, int>> fetchData() async {
    if (esp32Url.isNotEmpty) {
      final response = await http.get(Uri.parse('$esp32Url/data'));

      if (response.statusCode == 200) {
        return Map<String, int>.from(json.decode(response.body));
      } else {
        print(response);
        throw Exception('========== Error fetching data ============');
      }
    } else {
      throw Exception('========== ESP32 Not found ============');
    }
  }
}
