import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/github_release.dart';
import 'package:url_launcher/url_launcher.dart' as ulaunch;

class ReleaseNotesScreen extends StatelessWidget {
  final String owner;
  final String repo;

  const ReleaseNotesScreen({
    Key? key,
    required this.owner,
    required this.repo,
  }) : super(key: key);

  Future<List<GitHubRelease>> fetchReleases() async {
    final url = Uri.parse('https://api.github.com/repos/$owner/$repo/releases');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> releasesJson = jsonDecode(response.body);
      return releasesJson.map((json) => GitHubRelease.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load releases');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Releases')),
      body: FutureBuilder<List<GitHubRelease>>(
        future: fetchReleases(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No release notes found.'),
            );
          } else {
            final releases = snapshot.data!;
            return ListView.builder(
              itemCount: releases.length,
              itemBuilder: (context, index) {
                final release = releases[index];
                return ListTile(
                  trailing: Icon(Icons.link),
                  title: Text(release.name),
                  subtitle: Text(
                    release.body,
                    maxLines: 30,
                    overflow: TextOverflow.visible,
                  ),
                  onTap: () => _openReleaseUrl(context, release.htmlUrl),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _openReleaseUrl(BuildContext context, String url) async {
    await ulaunch.launchUrl(Uri.parse(url));
  }
}
